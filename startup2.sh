#!/bin/bash

APP_NAME="rsocket-client-test"
LOG_DIR="./logs"

echo "🧹 이전 컨테이너 정리 중..."
docker-compose down --remove-orphans

echo "🧼 기존 $APP_NAME 관련 이미지 삭제 중..."
docker images | grep "$APP_NAME" | awk '{print $3}' | xargs -r docker rmi -f

echo "📁 logs 디렉토리 정리 중..."
rm -rf $LOG_DIR
mkdir -p $LOG_DIR

echo "🚀 tester1 컨테이너 빌드 및 실행 시작..."
docker-compose up --build -d tester1

echo "⏳ 테스트 완료 대기 중..."
sleep 20

echo "📊 테스트 로그 분석 시작..."
node analyze-logs.js