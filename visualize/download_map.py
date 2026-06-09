import urllib.request
import ssl

ssl._create_default_https_context = ssl._create_unverified_context

# 使用pyecharts的地图数据
url = 'https://assets.pyecharts.org/assets/v5/maps/china.js'
try:
    response = urllib.request.urlopen(url, timeout=60)
    data = response.read()
    
    with open('china.js', 'wb') as f:
        f.write(data)
    
    print('文件下载成功')
except Exception as e:
    print(f'下载失败: {e}')