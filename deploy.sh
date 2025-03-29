#!/bin/bash


# .env 파일에서 환경 변수 불러오기
export $(cat /home/ubuntu/mall_infra/.env | xargs)

# 환경 변수 유효성 검사
if [ -z "$ACTIVE_ENV" ]; then
    echo "ACTIVE_ENV가 설정되지 않았습니다."
    exit 1
fi

echo "현재 ACTIVE_ENV: $ACTIVE_ENV"

# 각 서비스 포트 설정 (환경 변수에 맞게 설정)
declare -A ports=(
  [product_blue]=8080
  [product_green]=8081
  [order_blue]=8084
  [order_green]=8085
  [cart_blue]=8082
  [cart_green]=8083
)

# 서버 응답 확인 함수
check_server_response() {
  local service=$1
  local port=$2
  local env=$3

  echo "Checking $service server ($env) on port $port..."

  # 서버에 HTTP 요청을 보내 응답 코드 확인
  STATUS=$(curl -o /dev/null -w "%{http_code}" "http://52.78.112.137:$port/$service/env")

  if [ "$STATUS" -eq 200 ]; then
    echo "$service $env server is up and running on port $port!"
  else
    echo "ERROR: $service $env server is down or unreachable on port $port!"
    # 서버 응답이 없으면 롤백
    #rollback
    exit 1
  fi
}

# 모든 서비스 확인 함수 (배열로 진행)
check_all_servers() {
  local env=$1
  local pids=()
  
  for service in product order cart; do
    local port_var="${service}_${env}"
    check_server_response "$service" "${ports[$port_var]}" "$env" &
    pids+=("$!")
  done

  for pid in "${pids[@]}"; do
    wait "$pid"
  done
}

# 롤백 함수
rollback() {
  echo "Rolling back deployment..."

  if [ "$ACTIVE_ENV" == "blue" ]; then
    PREV_ENV="blue"
    NEW_ENV="green"
  else
    PREV_ENV="green"
    NEW_ENV="blue"
  fi

  echo "ACTIVE_ENV=$NEW_ENV" > /home/ubuntu/mall_infra/.env
  export $(cat /home/ubuntu/mall_infra/.env | xargs)

  envsubst '${ACTIVE_ENV}' < /home/ubuntu/mall_infra/nginx/nginx.conf.template > /home/ubuntu/mall_infra/nginx/nginx.conf

  sudo docker-compose -f /home/ubuntu/mall_infra/docker-compose.$ACTIVE_ENV.yml down
  sudo docker-compose -f /home/ubuntu/mall_infra/docker-compose.$NEW_ENV.yml up -d
}

# 새로운 환경 결정
if [ "$ACTIVE_ENV" == "blue" ]; then
  PREV_ENV="blue"
  NEW_ENV="green"
else
  PREV_ENV="green"
  NEW_ENV="blue"
fi

echo "ACTIVE_ENV=$NEW_ENV" > /home/ubuntu/mall_infra/.env
export $(cat /home/ubuntu/mall_infra/.env | xargs)

envsubst '${ACTIVE_ENV}' < /home/ubuntu/mall_infra/nginx/nginx.conf.template > /home/ubuntu/mall_infra/nginx/nginx.conf

sudo docker-compose -f /home/ubuntu/mall_infra/docker-compose.$NEW_ENV.yml up -d

check_all_servers $NEW_ENV

echo "♻️ Nginx 재시작 중..."
sudo docker exec -i nginxserver nginx -s reload


#if sudo docker ps -a | grep "mall_.*_$PREV_ENV"; then
#  sudo docker-compose -f /home/ubuntu/mall_infra/docker-compose.$PREV_ENV.yml down
#else
#  echo "✅ No $PREV_ENV containers running. Skipping shutdown."
#fi

 for service in product order cart; do
        echo "mall_${service}_server_{PREV_ENV}"
	if sudo docker ps -a | grep "mall_${service}_server_${PREV_ENV}"; then
	sudo docker stop mall_${service}_server_${PREV_ENV}
	sudo docker rm mall_${service}_server_${PREV_ENV}
	fi
 done
