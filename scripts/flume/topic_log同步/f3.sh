#!/bin/bash

# Flume 主目录
FLUME_HOME=/home/hadoop/flume
# 配置文件路径
CONF_FILE=$FLUME_HOME/job/topic_log_to_hdfs.conf
# Agent 名称
AGENT_NAME=a1
# 进程标识（用于识别进程）
IDENTIFIER="kafka2_to_hdfs"

case $1 in
start)
    ps -ef | grep flume | grep $IDENTIFIER | grep -v grep
    if [ $? -eq 0 ]; then
        echo "Flume [$IDENTIFIER] 已经在运行！"
        exit 0
    fi

    echo "正在启动 Flume：$IDENTIFIER ..."
    nohup $FLUME_HOME/bin/flume-ng agent \
    -c $FLUME_HOME/conf \
    -f $CONF_FILE \
    -n $AGENT_NAME \
    -Dflume.application.name=$IDENTIFIER \
    >/dev/null 2>&1 &

    echo "启动成功！"
    ;;
stop)
    echo "正在停止 Flume：$IDENTIFIER ..."
    ps -ef | grep flume | grep $IDENTIFIER | grep -v grep | awk '{print $2}' | xargs kill -9 2>/dev/null
    echo "已停止！"
    ;;
restart)
    $0 stop
    sleep 2
    $0 start
    ;;
*)
    echo "用法：$0 start|stop|restart"
    ;;
esac
