# gv - Go Version Manager

**gv** (short for **G**o **V**ersion) is a lightweight, zero-dependency Go version manager for **Linux, macOS, and Windows (Git Bash/WSL)**.
Automatically switches Go version based on `go.mod`, or manually via `gv-use` – ideal for multi-project, multi-version development.

## Features

- 🚀 **One‑line install** – fully automated setup
- 🔄 **Smart switching** – automatically uses the version declared in `go.mod` when you `cd` into a project
- 🎛️ **Manual override** – switch to any installed version on demand with `gv-use` (add `-g` to persist across terminals)
- 📦 **Multi‑version support** – each version installed independently
- 🐧 **Cross‑platform** – Linux, macOS, Windows (Git Bash / WSL)
- 🌏 **Multi‑language UI** – auto‑detects system language (Simplified/Traditional Chinese, English, Japanese, Korean)
- 🌍 **Region‑aware mirror** – auto-selects `golang.google.cn` for China, `go.dev` for other regions; easily changeable via `gv-mirror`

## Quick Install

Open your terminal (Git Bash or WSL on Windows) and run:

```bash
curl -sSL https://raw.githubusercontent.com/EchoRealm-io/gv/main/install.sh | bash
```

After installation, **restart your terminal** or run `source ~/.bashrc` (Linux/macOS) or `source ~/.bash_profile` to apply.

## Usage

| Command                 | Description                                                                  | Example                                                     |
| ----------------------- | ---------------------------------------------------------------------------- | ----------------------------------------------------------- |
| `gv-install <version>`  | Install a specific version                                                   | `gv-install 1.21.5`                                         |
| `gv-use [-g] <version>` | Switch version (current session only; add `-g` to persist for new terminals) | `gv-use 1.20.6` / `gv-use -g 1.21.5`                        |
| `gv-list`               | List installed versions                                                      | `gv-list`                                                   |
| `gv-mirror [URL]`       | Show current mirror, or set a new one                                        | `gv-mirror` / `gv-mirror https://mirrors.aliyun.com/golang` |

## Configuration

You can customize settings by editing `~/.go-version-manager/defaults.sh` or by setting environment variables.

| Variable               | Default (Linux/macOS)                                   | Default (Windows)    | Description                       |
| ---------------------- | ------------------------------------------------------- | -------------------- | --------------------------------- |
| `GO_VERSIONS_DIR`      | `/usr/local`                                            | `$HOME/.go-versions` | Installation root                 |
| `GO_DOWNLOAD_BASE_URL` | `https://go.dev/dl` (auto: `golang.google.cn` in China) | same                 | Download mirror                   |
| `DEFAULT_GO_VERSION`   | `1.26.4`                                                | same                 | Fallback version when no `go.mod` |
| `MIN_GO_VERSION`       | `1.21`                                                  | same                 | Auto‑upgrade versions below this  |

## Uninstall

```bash
rm -rf ~/.go-version-manager ~/bin/go ~/.go_current_version
# Then remove the source lines from your ~/.bashrc or ~/.zshrc
```

## License

MIT
