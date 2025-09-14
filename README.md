# CXUtils

[CXUtils](https://github.com/Kenxu2022/CXUtils) 的前端仓库，使用 Flutter 构建。

# 使用

## Android
直接下载安装 Release 中的安装包，一般而言使用 `app-arm64-v8a-release.apk` 这个安装包即可。

## 其他平台
需要自行部署网页端，以下是简要流程：  
1. 下载并解压 Release 中的 `web.zip` 文件至可通过公网访问的服务器上
2. 在 Nginx 配置文件中添加站点配置，以下提供 Nginx 配置参考：
   ```conf
    server {
        listen 80;
        listen [::]:80;
        server_name $SERVER_NAME;
        return 301 https://$host$request_uri;
    }
    server {
        listen 443 ssl;
        listen [::]:443 ssl;
        http2 on;
        server_name $SERVER_NAME;
        root $WEBROOT;
        ssl_certificate $PATH_TO_CERTIFICATE;
        ssl_certificate_key $PATH_TO_KEY;
        # header for WASM
        add_header Cross-Origin-Embedder-Policy credentialless;
        add_header Cross-Origin-Opener-Policy same-origin;
    }
   ```
   为了确保 WASM 功能的正确运行，你需要修改 Nginx 自带的 mime.types 文件，将 `.mjs` 后缀添加至 `application/javascript` 中：
   ```conf
    application/javascript                           js mjs;
   ```
3. 配置 HTTPS 证书

> 由于网页需要调用摄像头，因此必须使用 HTTPS 协议连接至服务器

**特别提醒：若前后端域名不一致，需要在后端 Nginx 配置文件反向代理部分添加 CORS 策略**  
```conf
# CORS Policy
add_header 'Access-Control-Allow-Origin' '$FRONTEND_DOMAIN' always;
add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS' always;
add_header 'Access-Control-Allow-Headers' 'Content-Type, Authorization' always;
add_header 'Access-Control-Allow-Credentials' 'true' always;
# OPTION Request
if ($request_method = OPTIONS) {
    add_header 'Access-Control-Allow-Origin' '$FRONTEND_DOMAIN' always;
    add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS' always;
    add_header 'Access-Control-Allow-Headers' 'Content-Type, Authorization' always;
    add_header 'Access-Control-Allow-Credentials' 'true' always;
    add_header 'Access-Control-Max-Age' 86400;
    add_header 'Content-Length' 0;
    add_header 'Content-Type' 'text/plain charset=UTF-8';
    return 204;
}
```

# 配置

填写服务端地址，账号及密码，并同意摄像头权限。

关于定位：需要填写用于定位签到的地址（经纬度）和显示文字，相关信息可前往[百度坐标拾取系统](https://lbs.baidu.com/maptool/getpoint)获取。

# 许可

GNU GPLv3