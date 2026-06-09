#! /bin/bash

case $1 in
"start")
    echo " --------本地启动 Flume-------"
    nohup /home/hadoop/flume/bin/flume-ng agent --conf-file /home/hadoop/flume/job/file_to_kafka.conf --name a1 -Dflume.root.logger=INFO,console > /home/hadoop/flume/log1.txt 2>&1 &
;;

"stop")
    echo " --------本地停止 Flume-------"
    ps -ef | grep file_to_kafka | grep -v grep | awk '{print $2}' | xargs -r kill -9 2>/dev/null
;;
esac
