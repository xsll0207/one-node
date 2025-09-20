#!/usr/bin/env sh

PORT="${PORT:-8080}"
UUID="${UUID:-2584b733-9095-4bec-a7d5-62b473540f7a}"

# 1. 初始化目录
mkdir -p app/sing-box
cd app/sing-box

# 2. 下载并解压 sing-box
wget https://github.com/SagerNet/sing-box/releases/latest/download/sing-box-linux-amd64.tar.gz
tar -xzf sing-box-linux-amd64.tar.gz
mv sing-box-*/sing-box .
rm -rf sing-box-linux-amd64.tar.gz sing-box-*

# 3. 添加配置文件
cat << EOF > config.json
{
  "log": {"level": "info"},
  "inbounds": [
    {
      "type": "vless",
      "listen": "::",
      "listen_port": $PORT,
      "users": [
        {
          "uuid": "$UUID",
          "flow": "xtls-rprx-vision"
        }
      ],
      "tls": {
        "enabled": true,
        "server_name": "example.domain.com",
        "reality": {
          "enabled": true,
          "public_key": "YOUR_PUBLIC_KEY",
          "short_id": "YOUR_SHORT_ID"
        }
      }
    }
  ],
  "outbounds": [
    {
      "type": "direct"
    }
  ]
}
EOF

# 4. 创建启动脚本
cat << EOF > startup.sh
#!/usr/bin/env sh
$PWD/sing-box run -c $PWD/config.json &
EOF
chmod +x startup.sh

# 5. 启动 sing-box
$PWD/startup.sh

# 6. 输出节点信息
echo '---------------------------------------------------------------'
echo "vless://$UUID@example.domain.com:$PORT?encryption=none&security=reality&flow=xtls-rprx-vision&sni=example.domain.com&fp=chrome&type=tcp#idx-vless"
echo '---------------------------------------------------------------'
