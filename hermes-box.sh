#!/bin/bash
# ============================================================================
# Hermes Agent 终极工具箱 (整合版)
# 整合了 Hermes 安装与常用 VPS 优化功能 (借鉴 Kejilion 思路)
# ============================================================================

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
HERMES_HOME="$HOME/.hermes"

# --- 辅助函数 ---
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_ok()   { echo -e "${GREEN}[OK]${NC}   $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
read_any() { read -p "$(echo -e ${YELLOW}"按回车键继续..."${NC}) " dummy; }

# --- 核心功能: 安装 Hermes ---
install_hermes() {
    if command -v hermes &>/dev/null; then 
        echo -e "${YELLOW}Hermes 似乎已经安装了。${NC}"
        update_hermes
        return
    fi

    log_info "开始安装 Hermes Agent..."
    [ ! -f /usr/bin/git ] && { echo "缺少 Git，正在安装..."; apt-get update && apt-get install -y git curl; }
    
    # 设置环境变量以防安装失败
    export PATH="$HOME/.local/bin:$PATH"
    curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash

    export PATH="$HOME/.local/bin:$PATH"
    if command -v hermes &>/dev/null; then
        log_ok "Hermes 安装成功!"
        setup_hm_command
        hermes gateway install &>/dev/null
        hermes gateway start &>/dev/null || true
    else
        log_warn "安装似乎未成功，请检查网络。"
    fi
    read_any
}

# --- 核心功能: 生成 hm 命令 ---
setup_hm_command() {
    cat > /usr/local/bin/hm << 'HMEOF'
#!/bin/bash
BIN=$HOME/.hermes/hermes-agent/venv/bin
[ -d "$BIN" ] && export PATH="$BIN:$PATH"
if [ "$1" = "stop" ]; then hermes gateway stop; exit; fi
if [ "$1" = "status" ]; then hermes --version && pgrep -f gateway >/dev/null && echo "运行中" || echo "未运行"; exit; fi
pgrep -f "hermes.*gateway" >/dev/null || hermes gateway start
hermes
HMEOF
    chmod +x /usr/local/bin/hm
    log_ok "已创建 hm 命令到 /usr/local/bin/hm"
}

# --- 核心功能: 更新 Hermes ---
update_hermes() {
    if ! command -v hermes &>/dev/null; then install_hermes; return; fi
    log_info "正在更新 Hermes..."
    export PATH="$HOME/.local/bin:$PATH"
    hermes update
    log_ok "更新完成。"
    read_any
}

# --- 整合功能 1: BBR 优化 ---
setup_bbr() {
    if lsmod | grep -q bbr; then
        log_ok "BBR 已经开启。"
    else
        echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
        echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
        sysctl -p
        log_ok "BBR 已开启，建议重启后生效。"
    fi
    read_any
}

# --- 整合功能 2: Docker 安装 ---
install_docker() {
    if command -v docker &>/dev/null; then 
        log_ok "Docker 已安装: $(docker --version)"; read_any; return
    fi
    log_info "正在安装 Docker (使用一键脚本)..."
    curl -fsSL https://get.docker.com | bash
    systemctl enable --now docker
    log_ok "Docker 安装完成。"
    read_any
}

# --- 整合功能 3: Swap 管理 ---
add_swap() {
    if [ -z "$(swapon --show)" ]; then
        log_info "检测到没有 Swap，正在创建 1G Swap..."
        fallocate -l 1G /swapfile
        chmod 600 /swapfile
        mkswap /swapfile
        swapon /swapfile
        echo '/swapfile none swap sw 0 0' >> /etc/fstab
        log_ok "Swap 添加完成。"
    else
        log_ok "Swap 已存在。"
    fi
    read_any
}

# --- 整合功能 4: 系统清理 ---
clean_system() {
    log_info "正在清理系统垃圾..."
    apt-get autoremove -y
    apt-get clean
    rm -rf /tmp/* ~/tmp 2>/dev/null
    log_ok "清理完成，释放了空间。"
    read_any
}

# --- 整合功能 5: 防火墙管理 ---
manage_firewall() {
    if ! ufw status &>/dev/null; then apt-get install -y ufw; fi
    clear
    echo "=== 防火墙管理 (UFW) ==="
    echo "1. 开启防火墙"
    echo "2. 关闭防火墙"
    echo "3. 放行常用端口 (22, 80, 443)"
    echo "4. 查看端口状态"
    echo "0. 返回"
    read -p "选择: " c
    case $c in
        1) ufw enable; log_ok "防火墙已开启" ;;
        2) ufw disable; log_ok "防火墙已关闭" ;;
        3) ufw allow 22/tcp; ufw allow 80/tcp; ufw allow 443/tcp; log_ok "端口已放行" ;;
        4) ufw status numbered ;;
    esac
    read_any
}

# --- 整合功能 6: 监控查看 ---
show_status() {
    clear
    echo "=== 系统概况 ==="
    echo -n "系统负载: "; top -bn1 | head -n 1
    echo -n "内存使用: "; free -h | grep Mem
    echo -n "磁盘空间: "; df -h / | grep /
    echo ""
    echo "=== 运行中的服务 (筛选 Node/Python) ==="
    ps -ef | grep -E '(node|python|hermes)' | grep -v grep
    echo ""
    echo "=== 当前开放端口 ==="
    ss -tlnp
    read_any
}

# --- 整合功能 7: 备份 ---
backup_config() {
    local dir="$HOME/hermes_backups"
    mkdir -p $dir
    tar czf "$dir/hermes_$(date +%Y%m%d).tar.gz" -C $HOME .hermes
    log_ok "备份已完成: $dir/hermes_$(date +%Y%m%d).tar.gz"
    read_any
}

# --- 主菜单 ---
menu() {
    clear
    echo -e "${BLUE}╔══════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}          ${GREEN}Hermes Agent 终极工具箱${NC}             ${BLUE}║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════╝${NC}"
    command -v hermes &>/dev/null && echo -e " Hermes: ${GREEN}[已安装]${NC}" || echo -e " Hermes: ${RED}[未安装]${NC}"
    echo "=============================================="
    echo " 1. 一键安装 Hermes Agent (含 API 配置)"
    echo " 2. 进入 Hermes (一键启动 Gateway + 对话)"
    echo " 3. 更新 Hermes Agent"
    echo "----------------------------------------------"
    echo " 4. Docker 环境部署"
    echo " 5. 一键开启 BBR (网络加速)"
    echo " 6. 添加 Swap 虚拟内存 (防崩溃)"
    echo " 7. 防火墙端口管理 (UFW)"
    echo " 8. 系统垃圾清理"
    echo " 9. 备份 Hermes 配置"
    echo " 10. 系统负载与端口查看"
    echo "----------------------------------------------"
    echo " 11. 卸载 Hermes"
    echo " 0. 退出"
    echo "=============================================="
    read -p "输入数字: " n
    
    case $n in
        1) install_hermes ;;
        2) [ -x /usr/local/bin/hm ] && /usr/local/bin/hm || { log_warn "请先安装 Hermes"; read_any; } ;;
        3) update_hermes ;;
        4) install_docker ;;
        5) setup_bbr ;;
        6) add_swap ;;
        7) manage_firewall ;;
        8) clean_system ;;
        9) backup_config ;;
        10) show_status ;;
        11) rm -rf $HERMES_HOME /usr/local/bin/hm; log_ok "已卸载"; read_any ;;
        0) exit ;;
        *) log_warn "无效输入" ;;
    esac
}

menu
