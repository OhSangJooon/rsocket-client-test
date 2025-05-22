/*
* 실행 전 사용가능 포트 늘리고 실행 필요 개인 로컬 PC마다 포트 제한이 걸려있어 최대 요청량이 제한됨
* sysctl net.inet.ip.portrange.first 기본 : 49152
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
const clientCount = parseInt(process.env.CLIENT_COUNT || '5000');
const WS_URL = process.env.WS_URL || 'wss://queue.pass-dev-aptner.com/rsocket';
// const WS_URL = process.env.WS_URL || 'ws://192.168.0.31:7010/rsocket';
const ROUTE = 'queue.test';
const JWT_TOKEN = 'test';
const MAX_RETRY = 10;


const CHANNELS = [
    { channel: 'GOLF_FIRST_COME', facilityId: '34' },
    // { channel: 'GOLF_FIRST_COME', facilityId: '33' },
    // { channel: 'GOLF_TIMETABLE', facilityId: '35' },
    // { channel: 'GOLF_TIMETABLE', facilityId: '36' },
    // { channel: 'SEAT', facilityId: '44' },
    // { channel: 'SEAT', facilityId: '45' },
    // { channel: 'LOCKER', facilityId: '54' },
    // { channel: 'LOCKER', facilityId: '55' },
    // { channel: 'GUEST_ROOM', facilityId: '64' },
    // { channel: 'GUEST_ROOM', facilityId: '65' },
    // { channel: 'PRIVATE_ROOM', facilityId: '74' },
    // { channel: 'PRIVATE_ROOM', facilityId: '75' },
];

const getRandomLeaveSeconds = () => Math.floor(Math.random() * (50 - 10 + 1)) + 10; // 40초 안에 퇴장

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
        // 테스트하는 피씨마다 다르게 설정 필요
        const userId = '13' + (startIndex + i).toString().padStart(6, '0');
        // const leaveAfter = getRandomLeaveSeconds();
        const leaveAfter = 60;

        const { channel, facilityId } = CHANNELS[Math.floor(Math.random() * CHANNELS.length)];
        const data = { memberId: userId, channel, facilityId, aptId: '1100000001' };

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
        let heartbeatInterval = null;

        function sendHeartbeat(socket) {
            const heartbeatRoute = encodeRoute("queue.test-heart-beat");
            const heartbeatMetadata = encodeCompositeMetadata([
                [WellKnownMimeType.MESSAGE_RSOCKET_AUTHENTICATION, authMetadataBuffer],
                [WellKnownMimeType.MESSAGE_RSOCKET_ROUTING, heartbeatRoute],
            ]);

            socket.fireAndForget({
                data: Buffer.from(JSON.stringify(data)),
                metadata: heartbeatMetadata,
            });
        }

        function startHeartbeat(socket) {
            sendHeartbeat(socket);
            heartbeatInterval = setInterval(() => sendHeartbeat(socket), 20000); // 20초
        }

        function stopHeartbeat() {
            if (heartbeatInterval) {
                clearInterval(heartbeatInterval);
                heartbeatInterval = null;
            }
        }

        function attemptConnection() {
            const client = new RSocketClient({
                transport: new RSocketWebSocketClient({ url: WS_URL }, BufferEncoders),
                setup: {
                    dataMimeType: 'application/json',
                    metadataMimeType: 'message/x.rsocket.composite-metadata.v0',
                    keepAlive: 300_000,
                    lifetime: 720_000,
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
                        onNext: payload => {
                            const payloadData = JSON.parse(payload.data.toString('utf8'));
                            const memberId = payloadData.memberId;
                            const position = payloadData.position;

                            // 최초 1회만 로그 남김
                            if (!memberPositions[memberId]) {
                                memberPositions[memberId] = true;
                                log(`WaitNumber: memberId: ${memberId}, 순번: ${position}`);
                            }
                        },
                        onError: error => {},
                        onComplete: () => {
                            successCount++; total++;
                            setTimeout(() => {
                                log("Success:");
                                socket.close();
                                resolve();
                            }, leaveAfter * 1000); // 완료 이후 60초 뒤 소켓 제거
                        },
                    });

                    socket.connectionStatus().subscribe({
                        onSubscribe: sub => sub.request(2147483647),
                        onNext: status => {
                            if (status.kind === 'ERROR') {
                                stopHeartbeat();
                                if (++retryCount < MAX_RETRY) {
                                    log(`재시도 함: ${userId}`);
                                    setTimeout(attemptConnection, 10000);
                                } else {
                                    failCount++; total++;
                                    log(`❌Fail: 재시도 초과: ${userId}`);
                                    socket.close();
                                    resolve();
                                }
                            } else if (status.kind === 'CLOSED') {
                                stopHeartbeat();
                                socket.close();
                                resolve();
                            }
                        },
                        onError: error => {
                            log(`❌Fail: 상태 감시 오류: ${error.message}`);
                        },
                    });

                    startHeartbeat(socket); // ✅ 연결 성공 시 하트비트 시작

                },
                onError: error => {
                    failCount++; total++;
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
    // 테스트 시작 로그 출력
    log(`🔥 테스트 시작: CLIENT_START_INDEX=${startIndex}, CLIENT_COUNT=${clientCount}`);

    const delayMs = 1000; // 각 그룹 간의 실행 지연 (1초)
    const groupSize = 1000; // 한 번에 몇 개의 클라이언트를 생성할 것인지
    const groupCount = Math.ceil(clientCount / groupSize); // 전체 그룹 수 계산

    const allTasks = []; // 모든 클라이언트의 Promise들을 담을 배열

    // 클라이언트를 그룹 단위로 나눠서 실행
    for (let g = 0; g < groupCount; g++) {
        const start = g * groupSize;
        const end = Math.min((g + 1) * groupSize, clientCount);

        // 그룹 간 1초 지연 (TPS가 갑자기 몰리는 걸 방지하기 위해)
        await new Promise(resolve => setTimeout(resolve, delayMs));

        const groupTasks = [];
        for (let i = start; i < end; i++) {
            // 클라이언트 생성 및 연결 시도
            groupTasks.push(connectClient(i));
        }

        // 해당 그룹의 모든 클라이언트 작업들을 전체 작업 배열에 추가
        allTasks.push(...groupTasks);
    }

    // 모든 클라이언트 작업들이 끝날 때까지 대기
    await Promise.all(allTasks);

    // 최종 로그 출력
    log(`✅ DONE - Success: ${successCount}, Fail: ${failCount}, Total: ${total}`);

    // 로그 스트림 종료
    logger.end();

    // 스크립트 종료
    process.exit(0);
})();