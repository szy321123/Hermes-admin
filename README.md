# Hermes Admin 🛠️

> **Hermes Agent 一键安装与服务器运维工具箱**

集成了 **Hermes Agent** 的极简安装、启动管理，并融合了 **kejilion.sh** 的实用运维功能（BBR、Docker、Swap 管理）。
旨在让你在 VPS 上，既能轻松拥有强大的 AI Agent，又能顺手完成服务器优化。

---

## ✨ 核心功能

本项目提供两个版本的脚本，你可以根据需求选择：

### 📦 版本一：极简安装 (`hermes-install.sh`)
适合**只要装好 Hermes、拿到 `hm` 快捷命令**的用户。
- 纯净环境部署，无冗余代码。
- 自动拉取官方源安装。
- 自动配置 Gateway 服务。
- 生成全局命令 `hm`，输入即可唤醒 Agent。

### 🧰 版本二：终极工具箱 (`hermes-box.sh`)
适合**VPS 站长/运维需求**，安装与优化一步到位。
- **Agent 管理**：安装 / 更新 / 卸载 / 诊断。
- **一键启动**：自动拉起后台网关。
- **BBR 加速**：开启 TCP BBR 提升网络吞吐量。
- **Swap 管理**：自动添加 Swap 防止 Agent 内存溢出。
- **Docker 部署**：一键安装 Docker & Compose。
- **防火墙管理**：基于 UFW 的图形化端口管理。
- **系统监控与清理**：一键查看状态、清理垃圾、备份配置。

---

## 🚀 快速使用

### 1. 极简安装模式
如果你只需要安装 Hermes 并获得 `hm` 命令：

```bash
bash <(curl -sL https://raw.githubusercontent.com/szy321123/Hermes-admin/main/hermes-install.sh)
```
*完成后运行 `hm` 即可启动。*

### 2. 终极工具箱模式 (推荐)
如果你想顺便优化服务器（开启 BBR、安装 Docker 等）：

```bash
bash <(curl -sL https://raw.githubusercontent.com/szy321123/Hermes-admin/main/hermes-box.sh)
```
*运行后会出现交互式菜单，根据提示输入数字即可操作。*

---

## ❓ 常见问题

- **`hm` 命令怎么用？**
  - `hm` - 一键启动 Gateway 并进入对话。
  - `hm stop` - 停止后台 Gateway 服务。
  - `hm status` - 查看当前版本和运行状态。

- **如何更新 Hermes？**
  - 再次运行“终极工具箱”，选择更新选项即可，脚本会自动拉取最新代码和依赖。

- **如何恢复 OpenClaw 数据？**
  - 工具箱内置了数据迁移指引，或者直接运行官方命令 `hermes claw migrate`。

---

## 📜 参考与鸣谢

本脚本的核心逻辑与功能实现参考了以下优秀的开源项目：

1.  **[NousResearch/hermes-agent](https://github.com/NousResearch/hermes-agent)**
    -   核心的安装流程、Gateway 配置以及 Agent CLI 均源于官方仓库逻辑。
2.  **[kejilion/sh](https://github.com/kejilion/sh)**
    -   **运维工具箱模式**：一键脚本菜单的设计灵感。
    -   **服务器优化逻辑**：一键开启 BBR、Swap 虚拟内存配置、Docker 部署脚本、防火墙管理及系统清理逻辑。

---

<div align="center">

Made with ❤️ for VPS and AI Agents

</div>
