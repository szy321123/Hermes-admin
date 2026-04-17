#!/bin/bash
# Hermes Agent 极简安装脚本
# 修复了环境变量未生效和 gateway 报错问题
# 用法: bash hermes-install.sh

set -e

# 0. 环境准备
export PATH="$HOME/.local/bin:$PATH"
if ! command -v git &> /dev/null; then
    echo "正在安装 git..."
    apt update && apt install -y git >/dev/null
fi

# 1. 运行官方安装脚本
echo "正在安装 Hermes Agent (需要几分钟，请耐心等待)..."
curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash

# 2. 刷新路径并验证
export PATH="$HOME/.local/bin:$PATH"
if ! command -v hermes &> /dev/null; then
    echo "安装失败：未找到 hermes 命令。请检查上方日志。"
    exit 1
fi

# 3. 配置 Gateway (容错处理)
echo "正在配置 Gateway..."
hermes gateway install &>/dev/null || true 
hermes gateway start &>/dev/null || true 

# 4. 创建 hm 快捷命令
cat > "$HOME/.local/bin/hm" << 'HMEOF'
#!/bin/bash
# 动态查找路径
BIN_DIR="$HOME/.hermes/hermes-agent/venv/bin"
[ -d "$BIN_DIR" ] && export PATH="$BIN_DIR:$PATH"

[ ! -x "$(command -v hermes)" ] && { echo "未安装 hermes"; exit 1; }

echo "▶ 检查 Gateway..."
if ! pgrep -f "hermes.*gateway" >/dev/null; then
    hermes gateway start &
    sleep 2
    if [ "$(pgrep -c -f 'hermes.*gateway')" -eq 0 ]; then
        echo "Gateway 启动可能失败，请运行 'hermes gateway start' 检查"
    fi
fi

echo "▶ 正在进入终端..."
hermes
HMEOF
chmod +x "$HOME/.local/bin/hm"

# 5. 自动写入 PATH 到 Shell 配置
PROFILE="$HOME/.bashrc"
[ -f "$HOME/.zshrc" ] && PROFILE="$HOME/.zshrc"
if ! grep -q 'local/bin' "$PROFILE"; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$PROFILE"
fi

echo "✅ 安装完成！"
echo "请运行 'source $PROFILE' 立即生效，然后输入 'hm' 启动。"
