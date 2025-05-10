/*
* 실행 전 사용가능 포트 늘리고 실행 필요 개인 로컬 PC마다 포트 제한이 걸려있어 최대 요청량이 제한됨
* sysctl net.inet.ip.portrange.first
* sysctl net.inet.ip.portrange.last
* sudo sysctl -w net.inet.ip.portrange.first=10000
* */
global.WebSocket = require('ws');
const fs = require('fs');
const path = require('path');
const {
    RSocketClient,
    JsonSerializer,
    IdentitySerializer,
    BufferEncoders,
} = require('rsocket-core');
const RSocketWebSocketClient = require('rsocket-websocket-client').default;
const {
    encodeBearerAuthMetadata,
    encodeRoute,
    encodeCompositeMetadata,
    WellKnownMimeType,
} = require('rsocket-composite-metadata');

const startIndex = parseInt(process.env.CLIENT_START_INDEX || '0');
const clientCount = parseInt(process.env.CLIENT_COUNT || '2000');
const WS_URL = process.env.WS_URL || 'ws://host.docker.internal:7010/rsocket';
// const WS_URL = process.env.WS_URL || 'ws://192.168.0.31:7010/rsocket';
const ROUTE = 'queue.test';
const JWT_TOKEN = 'test';
const CHANNEL = 'GOLF_FIRST_COME';
const MAX_RETRY = 3;

const getRandomLeaveSeconds = () => Math.floor(Math.random() * (30 - 10 + 1)) + 10;

const logDir = path.join(__dirname, 'logs');
if (!fs.existsSync(logDir)) fs.mkdirSync(logDir);
const logFile = path.join(logDir, `client-${startIndex}.log`);
const logger = fs.createWriteStream(logFile, { flags: 'a' });

let successCount = 0, failCount = 0, total = 0;

function log(line) {
    logger.write(`[${new Date().toISOString()}] ${line}\n`);
}

const memberPositions = {}; // { memberId: true }

function connectClient(i) {
    return new Promise((resolve) => {
        const userId = '11' + (startIndex + i).toString().padStart(6, '0');
        const leaveAfter = getRandomLeaveSeconds();
        const data = { memberId: userId, channel: CHANNEL, facilityId: '34', aptId: '1100000001' };

        const authMetadataBuffer = encodeBearerAuthMetadata(JWT_TOKEN);
        const routeMetadataBuffer = encodeRoute(ROUTE);
        const compositeMetadata = encodeCompositeMetadata([
            [WellKnownMimeType.MESSAGE_RSOCKET_ROUTING, routeMetadataBuffer],
        ]);
        const setupMetadata = encodeCompositeMetadata([
            [WellKnownMimeType.MESSAGE_RSOCKET_AUTHENTICATION, authMetadataBuffer],
        ]);

        const dataPayload = Buffer.from(JSON.stringify(data));
        let retryCount = 0;

        function attemptConnection() {
            const client = new RSocketClient({
                transport: new RSocketWebSocketClient({ url: WS_URL }, BufferEncoders),
                setup: {
                    dataMimeType: 'application/json',
                    metadataMimeType: 'message/x.rsocket.composite-metadata.v0',
                    keepAlive: 180_000,
                    lifetime: 600_000,
                    payload: { data: null, metadata: setupMetadata },
                    serializers: { data: JsonSerializer, metadata: IdentitySerializer },
                },
            });

            client.connect().subscribe({
                onComplete: socket => {
                    let subscribed = false;

                    socket.requestStream({ data: dataPayload, metadata: compositeMetadata }).subscribe({
                        onSubscribe: sub => {
                            subscribed = true;
                            sub.request(2147483647);
                        },
                        onNext: () => {
                            const payloadData = JSON.parse(payload.data.toString('utf8'));
                            const memberId = payloadData.memberId;
                            const position = payloadData.position;

                            // 최초 1회만 로그 남김
                            if (!memberPositions[memberId]) {
                                memberPositions[memberId] = true;
                                log(`memberId: ${memberId}, 순번: ${position}`);
                            }
                        },
                        onError: error => {
                            if (!subscribed) return; // onSubscribe 보장
                            failCount++; total++;
                            log(`Fail: Stream error: ${error.message}`);
                            socket.close();
                            resolve();
                        },
                        onComplete: () => {
                            successCount++; total++;
                            log("Success:")
                            setTimeout(() => {
                                socket.close();
                                resolve();
                            }, 30000); // 완료 이후 30초 뒤 소켓 제거
                        },
                    });
                },
                onError: error => {
                    failCount++; total++;
                    log(`Connect error: ${error.message}`);
                    if (++retryCount <= MAX_RETRY) {
                        setTimeout(attemptConnection, 10000); // 재시도 10초에 한번씩 재시도 총 3회
                    } else {
                        log(`Fail: 연결 재시도 초과: ${userId}`);
                        resolve();
                    }
                },
            });
        }

        attemptConnection();
    });
}

(async () => {
    log(`🔥 테스트 시작: CLIENT_START_INDEX=${startIndex}, CLIENT_COUNT=${clientCount}`);

    // TPS 500
    const delayMs = 1000; // 1초 간격
    const groupSize = 500; // 1초당 100명
    const groupCount = Math.ceil(clientCount / groupSize);

    const allTasks = [];

    for (let g = 0; g < groupCount; g++) {
        const start = g * groupSize;
        const end = Math.min((g + 1) * groupSize, clientCount);

        await new Promise(resolve => setTimeout(resolve, delayMs)); // 1초 대기

        const groupTasks = [];
        for (let i = start; i < end; i++) {
            groupTasks.push(connectClient(i));
        }
        allTasks.push(...groupTasks);
    }

    await Promise.all(allTasks);

    log(`✅ DONE - Success: ${successCount}, Fail: ${failCount}, Total: ${total}`);
    logger.end();
    process.exit(0);
})();