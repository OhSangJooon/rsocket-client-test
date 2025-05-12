$APP_NAME = "rsocket-client-test"
$LOG_DIR = ".\logs"

Write-Host "🧹 이전 컨테이너 정리 중..."
docker-compose down --remove-orphans

Write-Host "🧼 기존 $APP_NAME 관련 이미지 삭제 중..."
$images = docker images | Select-String $APP_NAME
foreach ($image in $images) {
    $columns = ($image -split '\s+') | Where-Object { $_ -ne "" }
    if ($columns.Length -ge 3) {
        $imageId = $columns[2]
        Write-Host "  - 삭제 중: $imageId"
        docker rmi -f $imageId | Out-Null
    }
}

Write-Host "📁 logs 디렉토리 정리 중..."
if (Test-Path $LOG_DIR) {
    Remove-Item -Recurse -Force $LOG_DIR
}
New-Item -ItemType Directory -Path $LOG_DIR | Out-Null

Write-Host "🚀 컨테이너 빌드 및 순차 실행 시작..."

# tester1 ~ tester10 컨테이너를 115초 간격으로 실행
for ($i = 1; $i -le 10; $i++) {
    $SERVICE = "tester$i"
    Write-Host "▶️ $SERVICE 실행 중..."
    docker-compose up --build -d $SERVICE
    Start-Sleep -Seconds 85
}

Write-Host "⏳ 테스트 완료 대기 중..."
Start-Sleep -Seconds 60

Write-Host "📊 테스트 로그 분석 시작..."
node analyze-logs.js