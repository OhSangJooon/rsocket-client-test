const { testClient } = require('./index');
const { workerData, parentPort } = require('worker_threads');

function startWorker(offset, count) {
    for (let i = 0; i < count; i++) {
        const userId = '11' + (offset + i);
        testClient(userId, offset + i, (result) => {
            parentPort.postMessage({ type: result });
        });
    }
}

startWorker(workerData.offset, workerData.count);