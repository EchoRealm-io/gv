# gv - Go 版本管理器

**gv**（**G**o **V**ersion 的缩写）是一个轻量级、零依赖的 Go 版本管理器，支持 **Linux、macOS 和 Windows（Git Bash/WSL）**。
可根据 `go.mod` 自动切换 Go 版本，也支持通过 `gv-use` 手动指定——多项目多版本开发的理想选择。

## 特性

- 🚀 **一行安装** – 全自动设置
- 🔄 **智能切换** – `cd` 进入项目时自动使用 `go.mod` 中声明的版本
- 🎛️ **手动指定** – 随时通过 `gv-use` 切换到任意已安装版本（加 `-g` 可持久生效，新终端继承）
- 📦 **多版本共存** – 各版本独立安装
- 🐧 **跨平台** – Linux、macOS、Windows（Git Bash / WSL）
- 🌏 **多语言界面** – 自动检测系统语言（简体/繁体中文、英文、日文、韩文）
- 🌍 **区域感知镜像** – 中国地区自动使用 `golang.google.cn`，其他地区使用 `go.dev`；可通过 `gv-mirror` 随时更改

## 快速安装

打开终端（Windows 上使用 Git Bash 或 WSL），运行：

```bash
curl -sSL https://raw.githubusercontent.com/EchoRealm-io/gv/main/install.sh | bash
```

安装完成后，**重启终端**或执行 `source ~/.bashrc`（Linux/macOS）或 `source ~/.bash_profile` 使配置生效。

## 使用方法

| 命令                   | 说明                                                 | 示例                                                        |
| ---------------------- | ---------------------------------------------------- | ----------------------------------------------------------- |
| `gv-install <版本号>`  | 安装指定版本                                         | `gv-install 1.21.5`                                         |
| `gv-use [-g] <版本号>` | 切换版本（仅当前会话；加 `-g` 持久生效，新终端继承） | `gv-use 1.20.6` / `gv-use -g 1.21.5`                        |
| `gv-list`              | 列出已安装的版本                                     | `gv-list`                                                   |
| `gv-mirror [set\|add <url>]` | 管理下载镜像（查看列表、设置首选、添加新源）    | `gv-mirror` / `gv-mirror add https://mirrors.aliyun.com/golang` |
| `gv-help`              | 显示帮助和可用命令                                   | `gv-help`                                                   |

## 配置

你可以通过编辑 `~/.go-version-manager/defaults.sh` 或设置环境变量来自定义配置。

| 变量                   | 默认值（Linux/macOS）                                  | 默认值（Windows）    | 说明                     |
| ---------------------- | ------------------------------------------------------ | -------------------- | ------------------------ |
| `GO_VERSIONS_DIR`      | `/usr/local`                                           | `$HOME/.go-versions` | 安装根目录               |
| `GO_DOWNLOAD_BASE_URL` | `https://go.dev/dl`（中国自动使用 `golang.google.cn`） | 同上                 | 下载镜像地址             |
| `DEFAULT_GO_VERSION`   | `1.26.4`                                               | 同上                 | 无 `go.mod` 时的默认版本 |
| `MIN_GO_VERSION`       | `1.21`                                                 | 同上                 | 低于此版本自动升级       |

## 卸载

```bash
curl -sSL https://raw.githubusercontent.com/EchoRealm-io/gv/main/uninstall.sh | bash
```

卸载脚本会引导你完成 Go 版本删除、gv 文件清理和 shell 配置还原。

## 许可证

MIT
