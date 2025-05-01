const { Worker } = require('worker_threads');

const TOTAL_USERS = 3000;
const USERS_PER_SECOND = 300;
const INTERVAL_MS = 1000 / USERS_PER_SECOND;

let stats = { success: 0, fail: 0 };
let finished = 0;
const startTime = Date.now();

for (let i = 0; i < TOTAL_USERS; i++) {
    setTimeout(() => {
        const worker = new Worker('./worker.js', {
            workerData: { offset: i, count: 1 },
        });

        worker.on('message', msg => {
            if (msg.type === 'success') stats.success++;
            if (msg.type === 'fail') stats.fail++;
            finished++;

            if (finished === TOTAL_USERS) {
                const endTime = Date.now();
                const elapsedSec = ((endTime - startTime) / 1000).toFixed(2);
                const successRate = ((stats.success / TOTAL_USERS) * 100).toFixed(2);
                console.log(`\n✅ 테스트 완료: ${TOTAL_USERS}명`);
                console.log(`⏱ 총 소요 시간: ${elapsedSec}초`);
                console.log(`📊 평균 성공률: ${successRate}%`);
                process.exit(0);
            }
        });

        worker.on('error', err => {
            console.error(`❌ 워커 에러 발생 [${i}]:`, err);
        });

        worker.on('exit', () => {});
    }, i * INTERVAL_MS);
}

setInterval(() => {
    console.log(`[통계] 입장: ${stats.success}, 실패: ${stats.fail}`);
}, 3000);