#!/bin/bash
# Hermes Agent 极简安装脚本
# 用法: bash hermes-install.sh

set -e

echo "正在安装 Hermes Agent..."
curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash

echo "配置 Gateway..."
hermes gateway install
hermes gateway start

cat > /usr/local/bin/hm << 'EOF'
#!/bin/bash
BIN=$HOME/.hermes/hermes-agent/venv/bin
[ -d "$BIN" ] && export PATH="$BIN:$PATH"
pgrep -f "hermes gateway" >/dev/null || hermes gateway start
hermes
EOF
chmod +x /usr/local/bin/hm

echo ""
echo "安装完成! 输入 hm 即可启动"
