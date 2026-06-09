#!/bin/bash
DATA_HOME=/home/opt/mock
MAXWELL_HOME=/home/hadoop/maxwell

# 数据生成：先改配置 → 再运行jar
function mock_data() {
  local date=$1
  
  # ======================
  # 第一步：先修改配置文件
  # ======================
  echo "✅ 正在修改配置文件：mock.date = $date"
  sed -i "/mock.date/s/.*/mock.date: \"$date\"/" $DATA_HOME/application.yml
  
  # ======================
  # 第二步：再运行 jar 包
  # ======================
  echo "✅ 开始生成 $date 的模拟数据（控制台输出）..."
  cd $DATA_HOME
  java -jar "gmall-remake-mock.jar"
  
  echo -e "\n🎉 $date 数据生成完成！"
}

# 设置 Maxwell 历史时间戳
function set_maxwell_history_date() {
  local history_date=$1
  echo "✅ 设置 Maxwell 时间戳 = $history_date"
  sed -i "/mock_date/s/.*/mock_date=$history_date/" $MAXWELL_HOME/config.properties
  $MAXWELL_HOME/bin/mxw.sh restart
  sleep 3
}

# ======================
# 主逻辑
# ======================
case $1 in
"init")
  [ $2 ] && do_date=$2 || do_date='2022-02-21'
  sed -i "/mock.clear.busi/s/.*/mock.clear.busi: 1/" $DATA_HOME/application.yml
  sed -i "/mock.clear.user/s/.*/mock.clear.user: 1/" $DATA_HOME/application.yml
  mock_data $(date -d "$do_date -6 days" +%F)
  sed -i "/mock.clear.busi/s/.*/mock.clear.busi: 0/" $DATA_HOME/application.yml
  sed -i "/mock.clear.user/s/.*/mock.clear.user: 0/" $DATA_HOME/application.yml
  for ((i=5;i>=0;i--)); do
    mock_data $(date -d "$do_date -$i days" +%F)
  done
  ;;

[0-9][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9])
    # 1. 设置Maxwell历史时间
    set_maxwell_history_date $1
    
    # 2. 先改配置 → 再生成数据
    mock_data $1
    
    echo -e "\n========================================"
    echo "✅ 全部完成！"
    echo "✅ 配置已修改"
    echo "✅ 数据已生成"
    echo "✅ Maxwell ts = $1"
    echo "========================================"
    ;;

*)
    echo "用法："
    echo "   sh mock.sh 2022-06-08"
    echo "   sh mock.sh init"
    ;;
esac
