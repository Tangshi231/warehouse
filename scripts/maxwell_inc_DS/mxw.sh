#!/bin/bash
# Maxwell 启停管理脚本
MAXWELL_HOME=/home/hadoop/maxwell
LOG_FILE=${MAXWELL_HOME}/maxwell.log

# 检查进程是否运行
is_running() {
    ps -ef | grep maxwell | grep -v grep | grep -v "$0" > /dev/null
    return $?
}

# 主逻辑
case "$1" in
start)
    if is_running; then
        echo "Maxwell 已在运行，无需重复启动"
        exit 0
    fi
    echo "正在启动 Maxwell..."
    nohup ${MAXWELL_HOME}/bin/maxwell \
    --user=maxwell \
    --password=123456 \
    --host=192.168.245.128 \
    --port=3306 \
    --producer=kafka \
    --kafka.bootstrap.servers=master:9092 \
    --kafka_topic=maxwell \
    --output_ddl=true \
    --jdbc_options="serverTimezone=Asia/Shanghai&useSSL=false" \
    > ${LOG_FILE} 2>&1 &
    echo "Maxwell 启动成功，PID: $!"
    echo "日志路径: ${LOG_FILE}"
    ;;

stop)
    if ! is_running; then
        echo "Maxwell 未运行"
        exit 0
    fi
    echo "正在停止 Maxwell..."
    PID=$(ps -ef | grep maxwell | grep -v grep | grep -v "$0" | awk '{print $2}')
    kill -9 ${PID}
    echo "Maxwell 进程 ${PID} 已停止"
    ;;

status)
    if is_running; then
        echo "✅ Maxwell 正在运行"
        ps -ef | grep maxwell | grep -v grep | grep -v "$0"
    else
        echo "❌ Maxwell 未运行"
    fi
    ;;

restart)
    echo "正在重启 Maxwell..."
    $0 stop
    sleep 2
    $0 start
    ;;

*)
    echo "参数错误！用法：$0 start | stop | status | restart"
    exit 1
;;
esac