# scripts 目录说明

本目录存放离线数仓项目的脚本文件，包含建表、数据同步、数据装载等功能脚本。

## 目录结构

| 目录/文件 | 描述 |
| :--- | :--- |
| `create_tables_initial.sql` | ODS层和DWD层表结构创建及首日数据插入 |
| `datax_full_DS/` | DataX全量同步脚本，用于MySQL到HDFS的数据同步 |
| `flume/` | Flume配置脚本，包含日志采集、增量业务采集及拦截器代码 |
| `hive/` | Hive每日数据装载脚本，包含各层数据处理 |
| `maxwell_inc_DS/` | Maxwell启动脚本，用于增量采集MySQL binlog |
| `mock/` | 模拟数据生成脚本，用于生成测试数据 |

## 子目录说明

### datax_full_DS/

DataX全量同步相关脚本：
- `gen_import_config.py`：生成DataX配置文件的Python脚本
- `gen_import_config.sh`：生成DataX配置文件的Shell脚本
- `mysql_to_hdfs_full.sh`：MySQL到HDFS全量同步执行脚本

### flume/

Flume数据采集相关脚本和代码：
- `flume-interceptors/`：Flume拦截器Java代码
  - `ETLInterceptor.java`：ETL数据清洗拦截器
  - `TimestampInterceptor.java`：时间戳拦截器
  - `TimestampAndTableNameInterceptor.java`：时间戳和表名拦截器
- `log采集/`：日志数据采集配置
  - `f1.sh`：日志采集启动脚本
  - `file_to_kafka.conf`：本地文件到Kafka的Flume配置
- `topic_db同步/`：Kafka业务数据到HDFS同步配置
  - `f2.sh`：业务数据同步启动脚本
  - `topic_db_to_hdfs.conf`：Kafka到HDFS的Flume配置
- `topic_log同步/`：Kafka日志数据到HDFS同步配置
  - `f3.sh`：日志数据同步启动脚本
  - `topic_log_to_hdfs.conf`：Kafka日志到HDFS的Flume配置

### hive/

Hive每日数据装载脚本：
- `hdfs_to_ods.sh`：HDFS数据导入ODS层
- `ods_to_dim.sh`：ODS层数据同步到DIM层
- `ods_to_dwd.sh`：ODS层数据同步到DWD层
- `dwd_to_dws_1d.sh`：DWD层数据聚合到DWS层（日粒度）
- `1d_to_nd.sh`：日粒度数据转换为N日累积数据
- `1d_to_td.sh`：日粒度数据转换为截止日累积数据
- `ads.sh`：DWS层数据聚合到ADS层

### maxwell_inc_DS/

Maxwell增量采集相关脚本：
- `mxw.sh`：Maxwell启动脚本，用于采集MySQL binlog到Kafka

### mock/

模拟数据生成脚本：
- `mock.sh`：生成电商业务模拟数据

## 使用方式

### 1. 创建表结构
```bash
# 执行建表脚本
hive -f create_tables_initial.sql
```

### 2. 生成模拟数据（可选）
```bash
# 初始化模式：生成连续7天数据（含清空现有数据）
cd mock && ./mock.sh init [日期]

# 单天模式：生成指定日期数据
cd mock && ./mock.sh 2022-06-08
```

### 3. 启动Maxwell增量采集
```bash
# 启动Maxwell
cd maxwell_inc_DS && ./mxw.sh start

# 停止Maxwell
cd maxwell_inc_DS && ./mxw.sh stop

# 查看状态
cd maxwell_inc_DS && ./mxw.sh status

# 重启Maxwell
cd maxwell_inc_DS && ./mxw.sh restart
```

### 4. 启动Flume采集
```bash
# 启动日志采集（本地文件→Kafka）
cd flume/log采集 && ./f1.sh start

# 停止日志采集
cd flume/log采集 && ./f1.sh stop

# 启动业务数据同步（Kafka→HDFS）
cd flume/topic_db同步 && ./f2.sh start

# 启动日志数据同步（Kafka→HDFS）
cd flume/topic_log同步 && ./f3.sh start
```

### 5. DataX全量同步
```bash
# 同步指定表（第二个参数为日期，可选，默认为前一天）
cd datax_full_DS && ./mysql_to_hdfs_full.sh activity_info 2022-06-08

# 同步所有全量表
cd datax_full_DS && ./mysql_to_hdfs_full.sh all
```

### 6. 每日Hive数据装载
```bash
# ODS层数据导入（第二个参数为日期，可选，默认为前一天）
cd hive && ./hdfs_to_ods.sh all 2022-06-08

# DIM层数据同步
cd hive && ./ods_to_dim.sh 2022-06-08

# DWD层数据同步（第一个参数为表名，第二个参数为日期）
cd hive && ./ods_to_dwd.sh dwd_trade_order_detail_inc 2022-06-08
cd hive && ./ods_to_dwd.sh all 2022-06-08

# DWS层日粒度聚合
cd hive && ./dwd_to_dws_1d.sh all 2022-06-08

# N日累积数据转换
cd hive && ./1d_to_nd.sh 2022-06-08

# 截止日累积数据转换
cd hive && ./1d_to_td.sh 2022-06-08

# ADS层指标计算
cd hive && ./ads.sh 2022-06-08
```

## 脚本参数说明

| 脚本 | 参数1 | 参数2 | 说明 |
| :--- | :--- | :--- | :--- |
| `mock.sh` | `init` 或 `YYYY-MM-DD` | 可选日期 | 初始化或生成指定日期数据 |
| `mxw.sh` | `start/stop/status/restart` | 无 | Maxwell启停管理 |
| `mysql_to_hdfs_full.sh` | 表名或 `all` | 可选日期 | 全量同步指定表或所有表 |
| `ods_to_dwd.sh` | 表名或 `all` | 可选日期 | DWD层同步指定表或所有表 |
| `f1.sh/f2.sh/f3.sh` | `start/stop` | 无 | Flume启停管理 |
| 其他hive脚本 | 表名或 `all` | 可选日期 | 数据装载，日期默认为前一天 |