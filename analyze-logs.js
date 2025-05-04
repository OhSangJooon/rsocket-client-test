const fs = require('fs');
const path = require('path');
const readline = require('readline');

const logDir = './logs';
let total = 0, success = 0, fail = 0;

async function analyzeFile(filePath) {
    const rl = readline.createInterface({
        input: fs.createReadStream(filePath),
        crlfDelay: Infinity,
    });

    for await (const line of rl) {
        if (line.includes('Success:')) {
            success += 1;
            total += 1;
        } else if (line.includes('Fail:')) {
            fail += 1;
            total += 1;
        }
    }
}

(async () => {
    const files = fs.readdirSync(logDir);

    for (const file of files) {
        await analyzeFile(path.join(logDir, file));
    }

    console.log(`📊 테스트 결과`);
    console.log(`✅ TPS : 100`);
    console.log(`✔ 성공: ${success}`);
    console.log(`❌ 실패: ${fail}`);
    console.log(`📦 총 시도 수: ${total}`);
    console.log(`📈 평균 성공률: ${total ? ((success / total) * 100).toFixed(2) : '0.00'}%`);
})();