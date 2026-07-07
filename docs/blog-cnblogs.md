# 写了个零依赖的 Go 版本管理器，`curl | bash` 完事

## 缘起

作为一个 Go 开发者，多版本管理是刚需。团队项目用 1.21，个人项目想尝鲜 1.26，开源项目还在 1.19——**不同项目不同版本的场景太常见了**。

市面上的方案我基本都试过：

- **gvm**：老牌工具，但已归档停更两年，Apple Silicon 上 SSL 报错，Windows 完全不支持
- **g（voidint）**：很好用，但得先用 Go 编译安装——问题是我装它就是为了管理 Go 版本，这有点鸡生蛋
- **asdf**：太重，需要 git + curl，配置一套插件下来新手直接劝退
- **手动 `tar -C /usr/local`**：切换版本靠改软链，忘了切就翻车

就没有一个 **零门槛、开箱即用、国内网络友好** 的方案吗？

于是我写了 **gv**（Go Version）。

---

## 一行命令安装

```bash
curl -sSL https://raw.githubusercontent.com/EchoRealm-io/gv/main/install.sh | bash
```

打开终端（Windows 用 Git Bash 或 WSL），粘贴回车。不需要装 Go，不需要 git，不需要 Homebrew——**只有 bash 一个依赖**，而所有主流系统的 bash 都是预装的。

![demo](https://raw.githubusercontent.com/EchoRealm-io/gv/main/demo/demo.gif)

安装过程全中文交互：

```
=== gv (Go Version Manager) 安装 ===
⚠️  检测到现有的 Go 安装
    路径:/usr/local/go
    来源:system-installed
    版本:go1.17.1

是否删除 /usr/local/go [Y/N] y
✅ 已删除旧 Go

Go 安装目录[默认: /usr/local]:
> （回车）
下载镜像地址[默认: https://go.dev/dl]:
> （回车）
✅ 安装完成!
```

自动检测旧 Go、自动清理、提示配置生效——每一步都有人性化的提示。

---

## 核心能力

### 1. 在线选版本

```bash
$ gv-install
  1. 1.26    ← 自动拉取所有可用大版本
  2. 1.25
  3. 1.24
  ...
请输入序号: 1

  1. 1.26.4  ← 展开显示补丁版本
  2. 1.26.3
  3. 1.26.2
请输入序号: 1

正在下载 go1.26.4.darwin-arm64.tar.gz ...
✅ 安装完成: /usr/local/go1.26.4
💡 已切换到 Go 1.26.4（当前会话），用 gv-use -g 持久生效
```

不用翻网页找版本号，不用拼 URL，全流程命令行搞定。

### 2. 多镜像自动回退

国内网络访问 `go.dev` 不稳定？gv 自动回退：

```
正在下载 https://go.dev/dl/go1.21.5.darwin-arm64.tar.gz ...
  curl: (18) Transferred a partial file
  ⚠️  回退尝试下一个镜像
正在下载 https://mirrors.aliyun.com/golang/go1.21.5.darwin-arm64.tar.gz ...
  ✅ 下载成功: mirrors.aliyun.com
```

默认三个镜像源：`go.dev` → `mirrors.aliyun.com` → `golang.google.cn`，哪个快用哪个。

### 3. 智能版本切换

```bash
# 临时切换（当前终端）
gv-use 1.21.5

# 持久切换（新终端生效）
gv-use -g 1.21.5

# 自动切换（根据 go.mod）
cd my-project   # go.mod 写的是 go 1.21
go build        # 自动用 1.21.x
```

`~/bin/go` wrapper 会向上查找 `go.mod`，自动匹配版本——不需要手动切来切去。

### 4. 零残留卸载

```bash
curl -sSL https://raw.githubusercontent.com/EchoRealm-io/gv/main/uninstall.sh | bash
```

交互式引导：列出已安装版本 → 询问删除 → 清理 shell 配置 → 还原被注释的旧配置 → 完成。

---

## 对比

|  | gv | g (voidint) | gvm | asdf |
|---|---|---|---|---|
| **安装** | `curl \| bash` | `go install` | `bash < <(curl)` | `git clone` |
| **零依赖** | ✅ 仅需 bash | ❌ 需 Go | ✅ bash | ❌ git+curl |
| **自动切换** | ✅ go.mod | ✅ .go-version | ✅ | ✅ |
| **多语言** | ✅ 5 种 | ❌ | ❌ | ❌ |
| **在线选版** | ✅ 交互式 | ❌ | ❌ | ❌ |
| **多镜像回退** | ✅ 自动 | ❌ | ❌ | ❌ |
| **旧 Go 清理** | ✅ | ❌ | ❌ | ❌ |
| **卸载工具** | ✅ | ❌ | ❌ | ❌ |
| **Windows** | ✅ WSL/Git Bash | ✅ 原生 | ❌ | ⚠️ WSL |

gv 选择了 **纯 bash + 零依赖** 的技术路线。这带来了一些天然的劣势——比如启动速度不如二进制、没有 SHA256 校验——但对于 "curl 完就能用" 的目标来说，这个取舍是值得的。

---

## 写在最后

gv 不是什么惊世骇俗的项目，它只是在合适的时机、用合适的方式，解决了一个具体的问题。如果你也用得上，欢迎 [Star ⭐](https://github.com/EchoRealm-io/gv) 和试用反馈。

> 项目地址：[https://github.com/EchoRealm-io/gv](https://github.com/EchoRealm-io/gv)
> 
> 安装：`curl -sSL https://raw.githubusercontent.com/EchoRealm-io/gv/main/install.sh | bash`
