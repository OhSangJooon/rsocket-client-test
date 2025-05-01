const { Worker } = require('worker_threads');

const TOTAL_USERS = 1000; // 총 유저
const USERS_PER_THREAD = 1; // 유저 별 스레드 수
const THREAD_COUNT = TOTAL_USERS / USERS_PER_THREAD;

let stats = { success: 0, fail: 0 };

for (let i = 0; i < THREAD_COUNT; i++) {
    const offset = i * USERS_PER_THREAD;
    const worker = new Worker('./worker.js', {
        workerData: { offset, count: USERS_PER_THREAD },
    });

    worker.on('message', msg => {
        if (msg.type === 'success') stats.success++;
        if (msg.type === 'fail') stats.fail++;
    });

    worker.on('error', err => {
        console.error('❌ 워커 에러 발생:', err);
    });

    worker.on('exit', code => {
        console.log(`✅ 워커 종료 (exit code: ${code})`);
    });
}

setInterval(() => {
    console.log(`[통계] 입장: ${stats.success}, 실패: ${stats.fail}`);
}, 3000);