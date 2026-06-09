# visualize 目录说明

本目录存放离线数仓项目的数据可视化相关文件，包含ECharts地图数据和可视化报表页面。

## 文件列表

| 文件 | 描述 |
| :--- | :--- |
| `china.js` | 中国地图GeoJSON数据，用于ECharts地图渲染 |
| `download_map.py` | Python脚本，用于下载pyecharts的中国地图数据 |
| `map_test.html` | 地图测试页面 |
| `render.html` | pyecharts生成的地图可视化单页 |
| `report.html` | 数据可视化报表大屏，包含KPI指标和多种图表 |

## 文件说明

### china.js

中国地图的GeoJSON地理数据文件，包含各省份的边界坐标信息，供ECharts地图组件使用。数据来源为pyecharts官方地图资源。

### download_map.py

下载中国地图数据的Python脚本，通过URL `https://assets.pyecharts.org/assets/v5/maps/china.js` 获取地图数据并保存为本地 `china.js` 文件。

### map_test.html

地图测试页面，用于验证地图数据加载和渲染效果。

### render.html

基于pyecharts生成的地图可视化页面，展示省份维度的订单分布数据。

### report.html

数据可视化报表大屏，包含：
- **KPI指标卡**：展示核心业务指标
- **图表组件**：包含多种ECharts图表（折线图、柱状图、饼图等）
- **词云图**：使用echarts-wordcloud插件生成
- **中国地图**：展示省份维度的数据分布
- **响应式布局**：使用CSS Grid实现多列卡片式布局