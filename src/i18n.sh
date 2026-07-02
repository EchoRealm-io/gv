#!/bin/bash
# ==================== Internationalization (i18n) ====================

detect_lang() {
    local lang="${LC_ALL:-$LANG}"
    lang="${lang%.*}"
    case "$lang" in
        zh_CN*) echo "zh_CN" ;;
        zh_TW*|zh_HK*) echo "zh_TW" ;;
        ja_JP*) echo "ja" ;;
        ko_KR*) echo "ko" ;;
        *) echo "en" ;;
    esac
}
export LANG_CODE=$(detect_lang)

msg() {
    local key="$1"
    local arg1="$2"
    local arg2="$3"
    case "$LANG_CODE" in
        zh_CN)
            case "$key" in
                go_install_usage) echo "用法: go-install <版本号>  例如: go-install 1.21.5" ;;
                version_installed) echo "版本 go$arg1 已安装在 $arg2" ;;
                download_start) echo "正在下载 $arg1 ..." ;;
                download_fail) echo "下载失败，请检查版本号或网络连接" ;;
                extract_sudo) echo "解压到 $arg1 (需要管理员权限)..." ;;
                install_complete) echo "✅ 安装完成: $arg1" ;;
                go_list_header) echo "已安装的 Go 版本：" ;;
                current_mark) echo "  <- 当前使用" ;;
                switch_usage) echo "用法: switch_go_version <版本号>  例如: switch_go_version 1.21.5" ;;
                version_not_installed) echo "❌ 版本 go$arg1 未安装，请先运行 go-install $arg1" ;;
                already_using) echo "✅ 已在 go$arg1" ;;
                switch_success) echo "✅ 已切换到 Go $arg1" ;;
                mirror_current) echo "当前镜像: $arg1" ;;
                mirror_usage) echo "用法: go-set-mirror <镜像URL>" ;;
                mirror_example) echo "示例: go-set-mirror https://mirrors.aliyun.com/golang" ;;
                mirror_set) echo "✅ 镜像已修改为: $arg1" ;;
                mirror_reload) echo "请执行 source $arg1 或重新打开终端使当前会话生效" ;;
                arch_not_supported) echo "不支持的架构: $arg1" ;;
                # Installer messages
                existing_go_detected) echo "检测到现有 Go 安装:" ;;
                existing_go_path) echo "路径" ;;
                existing_go_source) echo "来源" ;;
                existing_go_version) echo "版本" ;;
                existing_go_warn) echo "gv 将在 ${arg1:-/usr/local} 下独立管理 Go 版本。保留旧安装可能导致 IDE（VSCode、Trae）冲突。" ;;
                existing_go_cleanup_brew) echo "建议清理:"$'\n'"  1. brew uninstall go"$'\n'"  2. 从 shell 配置中删除 'export GOROOT=...' 及相关的 PATH 行" ;;
                existing_go_cleanup_system) echo "建议清理:"$'\n'"  1. sudo rm -rf $arg1"$'\n'"  2. 从 shell 配置中删除 'export GOROOT=...' 及相关的 PATH 行" ;;
                existing_go_cleanup_path) echo "建议：从 shell 配置中删除 'export GOROOT=...' 及相关的 PATH 行" ;;
                existing_go_continue) echo "是否继续？（不会删除旧 Go）[Y/n]:" ;;
                existing_go_abort) echo "已取消。请先卸载旧版本 Go，然后重新运行 gv 安装程序。" ;;
                old_config_detected) echo "在以下文件中检测到旧 Go 配置:" ;;
                old_config_warn) echo "gv 会自动管理 GOROOT 和 PATH。旧配置可能产生冲突。你可以现在删除，或保留作为 GUI 应用（VSCode、Trae）的 fallback。" ;;
                old_config_prompt) echo "注释掉这些旧配置行？[Y/n]:" ;;
                old_config_commented) echo "✅ 旧 Go 配置行已注释" ;;
                old_config_kept) echo "保留旧配置行。gv 会在终端会话中覆盖它们。VSCode / Trae 将继续使用旧 Go 安装。" ;;
                vscode_hint) echo "💡 VSCode / Trae 用户：Go 扩展不会读取你的 shell 配置。" ;;
                vscode_hint_detail) echo "   请在 VSCode 设置中将 'go.goroot' 指向 gv 管理的版本，例如: ${arg1}/go${arg2}" ;;
                *) echo "Unknown message" ;;
            esac
            ;;
        zh_TW)
            case "$key" in
                go_install_usage) echo "用法: go-install <版本號>  例如: go-install 1.21.5" ;;
                version_installed) echo "版本 go$arg1 已安裝在 $arg2" ;;
                download_start) echo "正在下載 $arg1 ..." ;;
                download_fail) echo "下載失敗，請檢查版本號或網路連線" ;;
                extract_sudo) echo "解壓縮到 $arg1 (需要管理員權限)..." ;;
                install_complete) echo "✅ 安裝完成: $arg1" ;;
                go_list_header) echo "已安裝的 Go 版本：" ;;
                current_mark) echo "  <- 目前使用" ;;
                switch_usage) echo "用法: switch_go_version <版本號>  例如: switch_go_version 1.21.5" ;;
                version_not_installed) echo "❌ 版本 go$arg1 未安裝，請先執行 go-install $arg1" ;;
                already_using) echo "✅ 已在 go$arg1" ;;
                switch_success) echo "✅ 已切換至 Go $arg1" ;;
                mirror_current) echo "目前鏡像: $arg1" ;;
                mirror_usage) echo "用法: go-set-mirror <鏡像URL>" ;;
                mirror_example) echo "範例: go-set-mirror https://mirrors.aliyun.com/golang" ;;
                mirror_set) echo "✅ 鏡像已修改為: $arg1" ;;
                mirror_reload) echo "請執行 source $arg1 或重新開啟終端機使目前會話生效" ;;
                arch_not_supported) echo "不支援的架構: $arg1" ;;
                # Installer messages
                existing_go_detected) echo "偵測到現有 Go 安裝:" ;;
                existing_go_path) echo "路徑" ;;
                existing_go_source) echo "來源" ;;
                existing_go_version) echo "版本" ;;
                existing_go_warn) echo "gv 將在 ${arg1:-/usr/local} 下獨立管理 Go 版本。保留舊安裝可能導致 IDE（VSCode、Trae）衝突。" ;;
                existing_go_cleanup_brew) echo "建議清理:"$'\n'"  1. brew uninstall go"$'\n'"  2. 從 shell 配置中刪除 'export GOROOT=...' 及相關的 PATH 行" ;;
                existing_go_cleanup_system) echo "建議清理:"$'\n'"  1. sudo rm -rf $arg1"$'\n'"  2. 從 shell 配置中刪除 'export GOROOT=...' 及相關的 PATH 行" ;;
                existing_go_cleanup_path) echo "建議：從 shell 配置中刪除 'export GOROOT=...' 及相關的 PATH 行" ;;
                existing_go_continue) echo "是否繼續？（不會刪除舊 Go）[Y/n]:" ;;
                existing_go_abort) echo "已取消。請先解除安裝舊版本 Go，然後重新執行 gv 安裝程式。" ;;
                old_config_detected) echo "在以下檔案中檢測到舊 Go 配置:" ;;
                old_config_warn) echo "gv 會自動管理 GOROOT 和 PATH。舊配置可能產生衝突。你可以現在刪除，或保留作為 GUI 應用（VSCode、Trae）的 fallback。" ;;
                old_config_prompt) echo "註解掉這些舊配置行？[Y/n]:" ;;
                old_config_commented) echo "✅ 舊 Go 配置行已註解" ;;
                old_config_kept) echo "保留舊配置行。gv 會在終端機工作階段中覆蓋它們。VSCode / Trae 將繼續使用舊 Go 安裝。" ;;
                vscode_hint) echo "💡 VSCode / Trae 使用者：Go 擴充功能不會讀取你的 shell 配置。" ;;
                vscode_hint_detail) echo "   請在 VSCode 設定中將 'go.goroot' 指向 gv 管理的版本，例如: ${arg1}/go${arg2}" ;;
                *) echo "Unknown message" ;;
            esac
            ;;
        ja)
            case "$key" in
                go_install_usage) echo "使用方法: go-install <バージョン>  例: go-install 1.21.5" ;;
                version_installed) echo "バージョン go$arg1 は $arg2 にインストール済みです" ;;
                download_start) echo "ダウンロード中 $arg1 ..." ;;
                download_fail) echo "ダウンロードに失敗しました。バージョンまたはネットワークを確認してください" ;;
                extract_sudo) echo "$arg1 に展開中 (管理者権限が必要)..." ;;
                install_complete) echo "✅ インストール完了: $arg1" ;;
                go_list_header) echo "インストール済みの Go バージョン：" ;;
                current_mark) echo "  <- 現在使用中" ;;
                switch_usage) echo "使用方法: switch_go_version <バージョン>  例: switch_go_version 1.21.5" ;;
                version_not_installed) echo "❌ バージョン go$arg1 はインストールされていません。go-install $arg1 を実行してください" ;;
                already_using) echo "✅ 既に go$arg1 を使用中です" ;;
                switch_success) echo "✅ Go $arg1 に切り替えました" ;;
                mirror_current) echo "現在のミラー: $arg1" ;;
                mirror_usage) echo "使用方法: go-set-mirror <ミラーURL>" ;;
                mirror_example) echo "例: go-set-mirror https://mirrors.aliyun.com/golang" ;;
                mirror_set) echo "✅ ミラーを $arg1 に設定しました" ;;
                mirror_reload) echo "source $arg1 を実行するか、ターミナルを再起動して現在のセッションに反映してください" ;;
                arch_not_supported) echo "非対応のアーキテクチャ: $arg1" ;;
                # Installer messages
                existing_go_detected) echo "既存の Go インストールを検出:" ;;
                existing_go_path) echo "パス" ;;
                existing_go_source) echo "ソース" ;;
                existing_go_version) echo "バージョン" ;;
                existing_go_warn) echo "gv は ${arg1:-/usr/local} に独立して Go バージョンを管理します。古いインストールを残すと IDE（VSCode、Trae）で競合が発生する可能性があります。" ;;
                existing_go_cleanup_brew) echo "推奨されるクリーンアップ:"$'\n'"  1. brew uninstall go"$'\n'"  2. シェル設定から 'export GOROOT=...' と関連する PATH 行を削除" ;;
                existing_go_cleanup_system) echo "推奨されるクリーンアップ:"$'\n'"  1. sudo rm -rf $arg1"$'\n'"  2. シェル設定から 'export GOROOT=...' と関連する PATH 行を削除" ;;
                existing_go_cleanup_path) echo "推奨: シェル設定から 'export GOROOT=...' と関連する PATH 行を削除" ;;
                existing_go_continue) echo "続行しますか？（古い Go は削除されません）[Y/n]:" ;;
                existing_go_abort) echo "中断しました。最初に古いバージョンの Go をアンインストールしてから、gv インストーラーを再実行してください。" ;;
                old_config_detected) echo "以下のファイルで古い Go 設定を検出:" ;;
                old_config_warn) echo "gv が GOROOT と PATH を自動管理します。古い設定は競合の原因になる可能性があります。今すぐ削除するか、GUI アプリ（VSCode、Trae）のフォールバックとして保持できます。" ;;
                old_config_prompt) echo "これらの古い設定行をコメントアウトしますか？[Y/n]:" ;;
                old_config_commented) echo "✅ 古い Go 設定行をコメントアウトしました" ;;
                old_config_kept) echo "古い設定行を保持します。gv がターミナルセッションで上書きします。VSCode / Trae は引き続き古い Go インストールを使用します。" ;;
                vscode_hint) echo "💡 VSCode / Trae ユーザー: Go 拡張機能はシェル設定を読み取りません。" ;;
                vscode_hint_detail) echo "   VSCode 設定で 'go.goroot' を gv 管理のバージョンに設定してください。例: ${arg1}/go${arg2}" ;;
                *) echo "Unknown message" ;;
            esac
            ;;
        ko)
            case "$key" in
                go_install_usage) echo "사용법: go-install <버전>  예: go-install 1.21.5" ;;
                version_installed) echo "버전 go$arg1 이(가) $arg2 에 설치됨" ;;
                download_start) echo "다운로드 중 $arg1 ..." ;;
                download_fail) echo "다운로드 실패, 버전 또는 네트워크를 확인하세요" ;;
                extract_sudo) echo "$arg1 에 압축 해제 중 (관리자 권한 필요)..." ;;
                install_complete) echo "✅ 설치 완료: $arg1" ;;
                go_list_header) echo "설치된 Go 버전:" ;;
                current_mark) echo "  <- 현재 사용 중" ;;
                switch_usage) echo "사용법: switch_go_version <버전>  예: switch_go_version 1.21.5" ;;
                version_not_installed) echo "❌ 버전 go$arg1 이(가) 설치되지 않았습니다. go-install $arg1 을(를) 실행하세요" ;;
                already_using) echo "✅ 이미 go$arg1 을(를) 사용 중입니다" ;;
                switch_success) echo "✅ Go $arg1 (으)로 전환됨" ;;
                mirror_current) echo "현재 미러: $arg1" ;;
                mirror_usage) echo "사용법: go-set-mirror <미러URL>" ;;
                mirror_example) echo "예: go-set-mirror https://mirrors.aliyun.com/golang" ;;
                mirror_set) echo "✅ 미러가 $arg1 (으)로 설정됨" ;;
                mirror_reload) echo "source $arg1 을(를) 실행하거나 터미널을 다시 시작하여 현재 세션에 적용하세요" ;;
                arch_not_supported) echo "지원되지 않는 아키텍처: $arg1" ;;
                # Installer messages
                existing_go_detected) echo "기존 Go 설치 감지:" ;;
                existing_go_path) echo "경로" ;;
                existing_go_source) echo "소스" ;;
                existing_go_version) echo "버전" ;;
                existing_go_warn) echo "gv는 ${arg1:-/usr/local} 아래에 Go 버전을 독립적으로 관리합니다. 이전 설치를 남겨두면 IDE(VSCode, Trae)와 충돌할 수 있습니다." ;;
                existing_go_cleanup_brew) echo "권장 정리:"$'\n'"  1. brew uninstall go"$'\n'"  2. 셸 설정에서 'export GOROOT=...' 및 관련 PATH 줄 삭제" ;;
                existing_go_cleanup_system) echo "권장 정리:"$'\n'"  1. sudo rm -rf $arg1"$'\n'"  2. 셸 설정에서 'export GOROOT=...' 및 관련 PATH 줄 삭제" ;;
                existing_go_cleanup_path) echo "권장: 셸 설정에서 'export GOROOT=...' 및 관련 PATH 줄 삭제" ;;
                existing_go_continue) echo "계속하시겠습니까? (이전 Go는 삭제되지 않음) [Y/n]:" ;;
                existing_go_abort) echo "중단됨. 먼저 이전 Go 버전을 제거한 후 gv 설치 프로그램을 다시 실행하세요." ;;
                old_config_detected) echo "다음 파일에서 이전 Go 설정 감지:" ;;
                old_config_warn) echo "gv가 GOROOT 및 PATH를 자동으로 관리합니다. 이전 설정과 충돌할 수 있습니다. 지금 제거하거나 GUI 앱(VSCode, Trae)의 폴백으로 유지할 수 있습니다." ;;
                old_config_prompt) echo "이전 설정 줄을 주석 처리하시겠습니까? [Y/n]:" ;;
                old_config_commented) echo "✅ 이전 Go 설정 줄이 주석 처리됨" ;;
                old_config_kept) echo "이전 설정 줄을 유지합니다. gv가 터미널 세션에서 재정의합니다. VSCode / Trae는 계속 이전 Go 설치를 사용합니다." ;;
                vscode_hint) echo "💡 VSCode / Trae 사용자: Go 확장 기능이 셸 설정을 읽지 않습니다." ;;
                vscode_hint_detail) echo "   VSCode 설정에서 'go.goroot'를 gv 관리 버전으로 지정하세요. 예: ${arg1}/go${arg2}" ;;
                *) echo "Unknown message" ;;
            esac
            ;;
        *)  # English (default)
            case "$key" in
                go_install_usage) echo "Usage: go-install <version>  e.g. go-install 1.21.5" ;;
                version_installed) echo "Version go$arg1 already installed at $arg2" ;;
                download_start) echo "Downloading $arg1 ..." ;;
                download_fail) echo "Download failed, please check version or network" ;;
                extract_sudo) echo "Extracting to $arg1 (requires admin privilege)..." ;;
                install_complete) echo "✅ Installation complete: $arg1" ;;
                go_list_header) echo "Installed Go versions:" ;;
                current_mark) echo "  <- currently used" ;;
                switch_usage) echo "Usage: switch_go_version <version>  e.g. switch_go_version 1.21.5" ;;
                version_not_installed) echo "❌ Version go$arg1 not installed, please run go-install $arg1" ;;
                already_using) echo "✅ Already using go$arg1" ;;
                switch_success) echo "✅ Switched to Go $arg1" ;;
                mirror_current) echo "Current mirror: $arg1" ;;
                mirror_usage) echo "Usage: go-set-mirror <mirror URL>" ;;
                mirror_example) echo "Example: go-set-mirror https://mirrors.aliyun.com/golang" ;;
                mirror_set) echo "✅ Mirror set to: $arg1" ;;
                mirror_reload) echo "Please run source $arg1 or restart terminal to apply in current session" ;;
                arch_not_supported) echo "Unsupported architecture: $arg1" ;;
                # Installer messages
                existing_go_detected) echo "Existing Go installation detected:" ;;
                existing_go_path) echo "Path" ;;
                existing_go_source) echo "Source" ;;
                existing_go_version) echo "Version" ;;
                existing_go_warn) echo "gv manages its own Go versions independently under ${arg1:-/usr/local}. Leaving the old installation may cause conflicts in GUI apps (VSCode, Trae)." ;;
                existing_go_cleanup_brew) echo "Recommended cleanup:"$'\n'"  1. brew uninstall go"$'\n'"  2. Remove 'export GOROOT=...' and related PATH lines from your shell config" ;;
                existing_go_cleanup_system) echo "Recommended cleanup:"$'\n'"  1. sudo rm -rf $arg1"$'\n'"  2. Remove 'export GOROOT=...' and related PATH lines from your shell config" ;;
                existing_go_cleanup_path) echo "Recommended: remove 'export GOROOT=...' and related PATH lines from your shell config" ;;
                existing_go_continue) echo "Continue anyway? (old Go will NOT be removed) [Y/n]:" ;;
                existing_go_abort) echo "Aborted. Please uninstall the old Go version first, then re-run the gv installer." ;;
                old_config_detected) echo "Detected old Go configuration in:" ;;
                old_config_warn) echo "gv manages GOROOT and PATH automatically. Old settings may conflict. You can remove them now, or keep them as a fallback for GUI apps (VSCode, Trae)." ;;
                old_config_prompt) echo "Comment out these old lines? [Y/n]:" ;;
                old_config_commented) echo "✅ Old Go lines commented out" ;;
                old_config_kept) echo "Keeping old lines. gv will override them in terminal sessions. VSCode / Trae will still use the old Go installation." ;;
                vscode_hint) echo "💡 VSCode / Trae users: the Go extension won't use your shell config." ;;
                vscode_hint_detail) echo "   Set 'go.goroot' in VSCode settings to point to a gv-managed version, e.g.: ${arg1}/go${arg2}" ;;
                *) echo "Unknown message" ;;
            esac
            ;;
    esac
}
