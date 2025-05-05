global.WebSocket = require('ws');
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

// ===================== 🔥 설정 =====================
const clientCount = 7;
const WS_URL = 'ws://localhost:7010/rsocket';
const ROUTE = 'queue.test';
const JWT_TOKEN = 'test';
const CHANNEL = 'GOLF_FIRST_COME';
const MAX_RETRY = 3;
const getRandomLeaveSeconds = () => Math.floor(Math.random() * (40 - 30 + 1)) + 40;

// ===================== 📦 전역 상태 저장 =====================
const memberPositions = {}; // { memberId: { first: number, latest: number } }

function connectClient(i) {
    return new Promise((resolve) => {
        const userId = '11' + i.toString().padStart(6, '0');
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
                    keepAlive: 10000,
                    lifetime: 35000,
                    payload: { data: null, metadata: setupMetadata },
                    serializers: { data: JsonSerializer, metadata: IdentitySerializer },
                },
            });

            let subscribed = false;
            client.connect().subscribe({
                onComplete: socket => {
                    socket.requestStream({ data: dataPayload, metadata: compositeMetadata }).subscribe({
                        onSubscribe: sub => {
                            subscribed = true;
                            sub.request(2147483647);
                        },
                        onNext: payload => {
                            const payloadData = JSON.parse(payload.data.toString('utf8'));
                            const memberId = payloadData.memberId;
                            const position = payloadData.position;

                            if (!memberPositions[memberId]) {
                                memberPositions[memberId] = { first: position, latest: position };
                                console.log(`🟢 최초 순번 등록: ${memberId} => ${position}`);
                            } else {
                                memberPositions[memberId].latest = position;
                                const first = memberPositions[memberId].first;
                                const changed = first !== position ? '❗ 순번 불일치' : '';
                                console.log(`🔁 재연결: ${memberId} => 최초: ${first}, 현재: ${position} ${changed}`);
                            }
                        },
                        onError: error => {
                            console.log(`❌ ${userId} 스트림 에러: ${error.message}`);
                            if (++retryCount <= MAX_RETRY) {
                                console.log(`🔁 ${userId} 스트림 재시도 ${retryCount}/3`);
                                setTimeout(attemptConnection, 10000); // 소켓 완전 재시작
                            } else {
                                console.log(`❌ ${userId} 스트림 재시도 실패`);
                                resolve();
                            }
                        },
                        onComplete: () => {
                            console.log(`✅ 입장 완료: ${userId}`);
                            setTimeout(() => {
                                console.log(`✅ 입장 완료 종료!: ${userId}`);
                                socket.close();
                                resolve();
                            }, leaveAfter * 1000);
                        },
                    });
                },
                onError: error => {
                    console.log(`❌ ${userId} 연결 에러: ${error.message}`);
                    if (++retryCount <= MAX_RETRY) {
                        console.log(`🔄 ${userId} 연결 재시도 ${retryCount}/3`);
                        setTimeout(attemptConnection, 10000);
                    } else {
                        console.log(`❌ ${userId} 재시도 실패`);
                        resolve();
                    }
                },
            });
        }

        attemptConnection();
    });
}

// ===================== 🚀 실행 =====================
(async () => {
    for (let i = 0; i < clientCount; i++) {
        connectClient(i);
        await new Promise(res => setTimeout(res, 100)); // 100ms 간격
    }
})();