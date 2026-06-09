#!/bin/bash

DATAX_HOME=/home/hadoop/datax
DATAX_DATA=/home/hadoop/datax/job

handle_targetdir() {
  hadoop fs -rm -r $1 >/dev/null 2>&1
  hadoop fs -mkdir -p $1
}

import_data() {
  local datax_config=$1
  local target_dir=$2

  handle_targetdir "$target_dir"
  echo "正在处理 $1"
  python $DATAX_HOME/bin/datax.py -p"-Dtargetdir=$target_dir" $datax_config >/tmp/datax_run.log 2>&1
  if [ $? -ne 0 ]; then
    echo "处理失败, 日志如下:"
    cat /tmp/datax_run.log
  fi
  # rm -f /tmp/datax_run.log
}

# 获取表名、同步日期
tab=$1
if [ -n "$2" ]; then
    do_date=$2
else
    do_date=$(date -d "-1 day" +%F)
fi

# 目标全量表清单
table_list="activity_info activity_rule base_trademark cart_info base_category1 base_category2 base_category3 coupon_info sku_attr_value sku_sale_attr_value base_dic sku_info base_province spu_info base_region promotion_pos promotion_refer"

case ${tab} in
# 单表执行匹配
activity_info|activity_rule|base_trademark|cart_info|base_category1|base_category2|base_category3|coupon_info|sku_attr_value|sku_sale_attr_value|base_dic|sku_info|base_province|spu_info|base_region|promotion_pos|promotion_refer)
  # 库名改为db_gmall，json文件名：db_gmall.表名.json
  import_data $DATAX_DATA/import/db_gmall.${tab}.json /origin_data/db/${tab}_full/$do_date
  ;;
# all全量循环所有表
"all")
  for tmp in $table_list
  do
    import_data $DATAX_DATA/import/db_gmall.${tmp}.json /origin_data/db/${tmp}_full/$do_date
  done
  ;;
esac