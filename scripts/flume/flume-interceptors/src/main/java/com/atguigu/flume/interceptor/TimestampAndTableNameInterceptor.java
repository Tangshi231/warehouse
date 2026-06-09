package com.atguigu.flume.interceptor;

import com.alibaba.fastjson.JSONObject;
import org.apache.flume.Context;
import org.apache.flume.Event;
import org.apache.flume.interceptor.Interceptor;

import java.nio.charset.StandardCharsets;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Map;

public class TimestampAndTableNameInterceptor implements Interceptor {
    @Override
    public void initialize() {

    }

    /*
    * 将body当中data里的create_time， 放到header里的timestamp（毫秒格式）
    * 将body里的table， 放到header里的tableName
    * */
    @Override
    public Event intercept(Event event) {
        // 1 获取header 和body当中的数据
        Map<String, String> headers = event.getHeaders();
        byte[] body = event.getBody();
        String log = new String(body, StandardCharsets.UTF_8);

        // 2 解析body，提取 table 和 data里的 create_time
        JSONObject jsonObject = JSONObject.parseObject(log);
        String table = jsonObject.getString("table");
        JSONObject data = jsonObject.getJSONObject("data");
        String createTime = data.getString("create_time");

        // 3 将 create_time 转换为时间戳（毫秒）存入header
        // create_time格式：2026-06-01 23:28:59
        try {
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
            Date date = sdf.parse(createTime);
            long timestamp = date.getTime();
            headers.put("timestamp", String.valueOf(timestamp));
        } catch (ParseException e) {
            return null;
        }

        // 4 将 table 放到 header 当中的 tableName
        headers.put("tableName", table);

        return event;
    }

    @Override
    public List<Event> intercept(List<Event> list) {
        for (Event event : list) {
            intercept(event);
        }
        return list;
    }

    @Override
    public void close() {

    }

    public static class Builder implements Interceptor.Builder {

        @Override
        public Interceptor build() {
            return new TimestampAndTableNameInterceptor();
        }

        @Override
        public void configure(Context context) {

        }
    }
}
