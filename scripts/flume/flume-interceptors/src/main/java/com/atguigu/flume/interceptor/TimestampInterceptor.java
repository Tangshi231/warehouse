package com.atguigu.flume.interceptor;

import com.alibaba.fastjson.JSONObject;
import org.apache.flume.Context;
import org.apache.flume.Event;
import org.apache.flume.interceptor.Interceptor;

import java.nio.charset.StandardCharsets;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

public class TimestampInterceptor implements Interceptor {
    @Override
    public void initialize() {

    }

    /*
    * 将 body当中的ts， 赋值到header当中的 timestamp
    * 过滤掉非法JSON数据
    * */
    @Override
    public Event intercept(Event event) {
        try {
            // 1 解析 header和body
            Map<String, String> headers = event.getHeaders();
            byte[] body = event.getBody();
            String log = new String(body, StandardCharsets.UTF_8);

            // 2 将body中的 ts 提取出来（ts是Long类型）
            JSONObject jsonObject = JSONObject.parseObject(log);
            Long ts = jsonObject.getLong("ts");

            // 3 将 body当中的ts， 赋值到header当中的 timestamp
            headers.put("timestamp", String.valueOf(ts));
            return event;
        } catch (Exception e) {
            // JSON解析失败，丢弃该事件
            return null;
        }
    }

    @Override
    public List<Event> intercept(List<Event> list) {
        Iterator<Event> iterator = list.iterator();
        while (iterator.hasNext()) {
            Event event = iterator.next();
            if (intercept(event) == null) {
                iterator.remove();
            }
        }
        return list;
    }

    @Override
    public void close() {

    }

    public static class Builder implements Interceptor.Builder {

        @Override
        public Interceptor build() {
            return new TimestampInterceptor();
        }

        @Override
        public void configure(Context context) {

        }
    }
}
