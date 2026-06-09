#!/bin/bash
# DataX 全量同步配置生成脚本
# 生成维度全量表DataX配置文件
# Python路径：/opt/rh/rh-python38/root/usr/bin/python3
# 脚本路径：/home/hadoop/datax/bin/gen_import_config.py

echo "===== 开始生成全量同步配置文件 ====="

# 定义数据库名
DATABASE=db_gmall
# 需要生成全量JSON的表清单
table_list="activity_info activity_rule base_trademark cart_info base_category1 base_category2 base_category3 coupon_info sku_attr_value sku_sale_attr_value base_dic sku_info base_province spu_info base_region promotion_pos promotion_refer"

# 循环批量生成全量json配置
for table in $table_list
do
  /opt/rh/rh-python38/root/usr/bin/python3 /home/hadoop/datax/bin/gen_import_config.py -d ${DATABASE} -t ${table}
done

echo "===== 全量同步配置文件生成完成 ====="
