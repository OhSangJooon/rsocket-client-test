const {
    RSocketClient,
} = require('rsocket-core');
const RSocketWebSocketClient = require('rsocket-websocket-client').default;
const { JsonSerializer, IdentitySerializer } = require('rsocket-core');
const { BufferEncoders } = require('rsocket-core');
const {
    encodeBearerAuthMetadata,
    encodeRoute,
    encodeCompositeMetadata,
    WellKnownMimeType,
} = require('rsocket-composite-metadata');

const WS_URL = 'ws://localhost:7010/rsocket';
const ROUTE = 'queue.test';
const CHANNEL = 'golf-first';
const JWT_TOKEN = 'test';

function getRandomLeaveSeconds() {
    return Math.floor(Math.random() * (70 - 20 + 1)) + 20; // 20초~70초
}

function testClient(userId, i, onComplete) {
    const leaveAfter = getRandomLeaveSeconds();
    const data = { memberId: userId, channel: CHANNEL, facilityId: "10000001", aptId: "11111001" };

    const authMetadataBuffer = encodeBearerAuthMetadata(JWT_TOKEN);
    const routeMetadataBuffer = encodeRoute(ROUTE);

    const compositeMetadata = encodeCompositeMetadata([
        [WellKnownMimeType.MESSAGE_RSOCKET_ROUTING, routeMetadataBuffer],
    ]);
    const setupMetadata = encodeCompositeMetadata([
        [WellKnownMimeType.MESSAGE_RSOCKET_AUTHENTICATION, authMetadataBuffer],
    ]);

    const client = new RSocketClient({
        transport: new RSocketWebSocketClient({ url: WS_URL }, BufferEncoders),
        setup: {
            dataMimeType: 'application/json',
            metadataMimeType: 'message/x.rsocket.composite-metadata.v0',
            keepAlive: 60000,
            lifetime: 180000,
            payload: { data: null, metadata: setupMetadata },
            serializers: { data: JsonSerializer, metadata: IdentitySerializer },
        },
    });

    client.connect().subscribe({
        onComplete: socket => {
            const sub = socket.requestStream({
                data: Buffer.from(JSON.stringify(data)),
                metadata: compositeMetadata,
            });

            sub.subscribe({
                onSubscribe: s => s.request(2147483647),
                onNext: payload => {
                    const payloadData = JSON.parse(payload.data.toString('utf8'));
                    console.log(`[${i}] ✅ 나의 순번 : ${payloadData.position} 총 대기 인원: ${payloadData.totalWaiting}`);
                },
                onComplete: () => {
                    // console.log(`[${i}] 🎉 ${userId} 입장 완료 → ${leaveAfter}s 뒤 퇴장`);
                    onComplete('success'); // 입장 인원 카운팅
                    setTimeout(() => {
                        socket.close();
                    }, leaveAfter * 1000);
                },
                onError: error => {
                    onComplete('fail');
                    console.error(`[${i}] ❌ ${userId} stream error:`, error);
                    socket.close();
                },
            });
        },
        onError: error => {
            onComplete('fail');
            console.error(`[${i}] 🚫 연결 실패:`, error);
        },
    });
}

module.exports = { testClient };