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
                switch_usage) echo "用法: go-use [-g] <版本号>  例如: go-use 1.21.5 或 go-use -g 1.21.5（持久）" ;;
                version_not_installed) echo "❌ 版本 go$arg1 未安装，请先运行 go-install $arg1" ;;
                already_using) echo "✅ 已在 go$arg1" ;;
                switch_success) echo "✅ 已切换到 Go $arg1（仅当前会话生效）" ;;
                switch_persisted) echo "✅ 已切换到 Go $arg1（已持久化，新终端生效）" ;;
                mirror_current) echo "当前镜像: $arg1" ;;
                mirror_usage) echo "用法: go-mirror [URL]  不带参数显示当前镜像" ;;
                mirror_example) echo "示例: go-mirror https://mirrors.aliyun.com/golang" ;;
                mirror_set) echo "✅ 镜像已修改为: $arg1" ;;
                mirror_reload) echo "请执行 source $arg1 或重新打开终端使当前会话生效" ;;
                arch_not_supported) echo "不支持的架构: $arg1" ;;
                existing_go_detected) echo "检测到现有的 Go 安装" ;;
                existing_go_path) echo "路径" ;;
                existing_go_source) echo "来源" ;;
                existing_go_version) echo "版本" ;;
                existing_go_warn) echo "gv 将使用 $arg1 作为安装目录，建议先卸载现有 Go 以避免冲突" ;;
                existing_go_cleanup_brew) echo "建议执行: brew uninstall go" ;;
                existing_go_cleanup_system) echo "建议删除目录: $arg1" ;;
                existing_go_cleanup_path) echo "建议从 PATH 和 shell 配置文件中移除旧的 Go 路径" ;;
                existing_go_continue) echo "是否继续安装？[Y/n]" ;;
                existing_go_abort) echo "已取消安装" ;;
                old_config_detected) echo "检测到旧的 Go 配置" ;;
                old_config_warn) echo "这些配置可能与 gv 冲突，建议注释掉相关行" ;;
                old_config_prompt) echo "是否注释掉这些旧配置？[Y/n]" ;;
                old_config_commented) echo "✅ 已注释旧配置" ;;
                old_config_kept) echo "未修改旧配置（如遇问题可手动处理）" ;;
                vscode_hint) echo "VSCode 用户提示" ;;
                vscode_hint_detail) echo "在 settings.json 中设置: \"go.goroot\": \"$arg1/go$arg2\"" ;;
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
                switch_usage) echo "用法: go-use [-g] <版本號>  例如: go-use 1.21.5 或 go-use -g 1.21.5（持久）" ;;
                version_not_installed) echo "❌ 版本 go$arg1 未安裝，請先執行 go-install $arg1" ;;
                already_using) echo "✅ 已在 go$arg1" ;;
                switch_success) echo "✅ 已切換至 Go $arg1（僅當前會話生效）" ;;
                switch_persisted) echo "✅ 已切換至 Go $arg1（已持久化，新終端生效）" ;;
                mirror_current) echo "目前鏡像: $arg1" ;;
                mirror_usage) echo "用法: go-mirror [URL]  不帶參數顯示目前鏡像" ;;
                mirror_example) echo "範例: go-mirror https://mirrors.aliyun.com/golang" ;;
                mirror_set) echo "✅ 鏡像已修改為: $arg1" ;;
                mirror_reload) echo "請執行 source $arg1 或重新開啟終端機使目前會話生效" ;;
                arch_not_supported) echo "不支援的架構: $arg1" ;;
                existing_go_detected) echo "偵測到現有的 Go 安裝" ;;
                existing_go_path) echo "路徑" ;;
                existing_go_source) echo "來源" ;;
                existing_go_version) echo "版本" ;;
                existing_go_warn) echo "gv 將使用 $arg1 作為安裝目錄，建議先解除安裝現有 Go 以避免衝突" ;;
                existing_go_cleanup_brew) echo "建議執行: brew uninstall go" ;;
                existing_go_cleanup_system) echo "建議刪除目錄: $arg1" ;;
                existing_go_cleanup_path) echo "建議從 PATH 和 shell 設定檔中移除舊的 Go 路徑" ;;
                existing_go_continue) echo "是否繼續安裝？[Y/n]" ;;
                existing_go_abort) echo "已取消安裝" ;;
                old_config_detected) echo "偵測到舊的 Go 設定" ;;
                old_config_warn) echo "這些設定可能與 gv 衝突，建議註解掉相關行" ;;
                old_config_prompt) echo "是否註解掉這些舊設定？[Y/n]" ;;
                old_config_commented) echo "✅ 已註解舊設定" ;;
                old_config_kept) echo "未修改舊設定（如遇問題可手動處理）" ;;
                vscode_hint) echo "VSCode 使用者提示" ;;
                vscode_hint_detail) echo "在 settings.json 中設定: \"go.goroot\": \"$arg1/go$arg2\"" ;;
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
                switch_usage) echo "使用方法: go-use [-g] <バージョン>  例: go-use 1.21.5 または go-use -g 1.21.5（永続）" ;;
                version_not_installed) echo "❌ バージョン go$arg1 はインストールされていません。go-install $arg1 を実行してください" ;;
                already_using) echo "✅ 既に go$arg1 を使用中です" ;;
                switch_success) echo "✅ Go $arg1 に切り替えました（現在のセッションのみ）" ;;
                switch_persisted) echo "✅ Go $arg1 に切り替えました（永続化、新端末で有効）" ;;
                mirror_current) echo "現在のミラー: $arg1" ;;
                mirror_usage) echo "使用方法: go-mirror [URL]  引数なしで現在のミラーを表示" ;;
                mirror_example) echo "例: go-mirror https://mirrors.aliyun.com/golang" ;;
                mirror_set) echo "✅ ミラーを $arg1 に設定しました" ;;
                mirror_reload) echo "source $arg1 を実行するか、ターミナルを再起動して現在のセッションに反映してください" ;;
                arch_not_supported) echo "非対応のアーキテクチャ: $arg1" ;;
                existing_go_detected) echo "既存の Go インストールが検出されました" ;;
                existing_go_path) echo "パス" ;;
                existing_go_source) echo "ソース" ;;
                existing_go_version) echo "バージョン" ;;
                existing_go_warn) echo "gv は $arg1 をインストール先に使用します。競合を避けるため既存の Go をアンインストールすることを推奨します" ;;
                existing_go_cleanup_brew) echo "推奨: brew uninstall go を実行" ;;
                existing_go_cleanup_system) echo "推奨: ディレクトリ $arg1 を削除" ;;
                existing_go_cleanup_path) echo "推奨: PATH と shell 設定ファイルから古い Go パスを削除" ;;
                existing_go_continue) echo "インストールを続行しますか？[Y/n]" ;;
                existing_go_abort) echo "インストールを中止しました" ;;
                old_config_detected) echo "古い Go 設定を検出しました" ;;
                old_config_warn) echo "これらの設定は gv と競合する可能性があります。関連行をコメントアウトすることを推奨します" ;;
                old_config_prompt) echo "これらの古い設定をコメントアウトしますか？[Y/n]" ;;
                old_config_commented) echo "✅ 古い設定をコメントアウトしました" ;;
                old_config_kept) echo "古い設定は変更していません（問題があれば手動で処理してください）" ;;
                vscode_hint) echo "VSCode ユーザーへのヒント" ;;
                vscode_hint_detail) echo "settings.json で設定: \"go.goroot\": \"$arg1/go$arg2\"" ;;
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
                switch_usage) echo "사용법: go-use [-g] <버전>  예: go-use 1.21.5 또는 go-use -g 1.21.5（영구）" ;;
                version_not_installed) echo "❌ 버전 go$arg1 이(가) 설치되지 않았습니다. go-install $arg1 을(를) 실행하세요" ;;
                already_using) echo "✅ 이미 go$arg1 을(를) 사용 중입니다" ;;
                switch_success) echo "✅ Go $arg1 (으)로 전환됨 (현재 세션만)" ;;
                switch_persisted) echo "✅ Go $arg1 (으)로 전환됨 (영구 적용, 새 터미널에 반영)" ;;
                mirror_current) echo "현재 미러: $arg1" ;;
                mirror_usage) echo "사용법: go-mirror [URL]  인수 없으면 현재 미러 표시" ;;
                mirror_example) echo "예: go-mirror https://mirrors.aliyun.com/golang" ;;
                mirror_set) echo "✅ 미러가 $arg1 (으)로 설정됨" ;;
                mirror_reload) echo "source $arg1 을(를) 실행하거나 터미널을 다시 시작하여 현재 세션에 적용하세요" ;;
                arch_not_supported) echo "지원되지 않는 아키텍처: $arg1" ;;
                existing_go_detected) echo "기존 Go 설치가 감지되었습니다" ;;
                existing_go_path) echo "경로" ;;
                existing_go_source) echo "소스" ;;
                existing_go_version) echo "버전" ;;
                existing_go_warn) echo "gv가 $arg1 을(를) 설치 디렉터리로 사용합니다. 충돌을 피하려면 기존 Go 제거를 권장합니다" ;;
                existing_go_cleanup_brew) echo "권장: brew uninstall go 실행" ;;
                existing_go_cleanup_system) echo "권장: 디렉터리 $arg1 삭제" ;;
                existing_go_cleanup_path) echo "권장: PATH 와 shell 설정 파일에서 이전 Go 경로 제거" ;;
                existing_go_continue) echo "설치를 계속하시겠습니까? [Y/n]" ;;
                existing_go_abort) echo "설치가 취소되었습니다" ;;
                old_config_detected) echo "이전 Go 설정이 감지되었습니다" ;;
                old_config_warn) echo "이 설정들은 gv 와 충돌할 수 있습니다. 관련 줄을 주석 처리하는 것을 권장합니다" ;;
                old_config_prompt) echo "이 이전 설정들을 주석 처리하시겠습니까? [Y/n]" ;;
                old_config_commented) echo "✅ 이전 설정을 주석 처리했습니다" ;;
                old_config_kept) echo "이전 설정을 변경하지 않았습니다 (문제 발생 시 수동으로 처리하세요)" ;;
                vscode_hint) echo "VSCode 사용자 팁" ;;
                vscode_hint_detail) echo "settings.json 에서 설정: \"go.goroot\": \"$arg1/go$arg2\"" ;;
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
                switch_usage) echo "Usage: go-use [-g] <version>  e.g. go-use 1.21.5 or go-use -g 1.21.5 (persist)" ;;
                version_not_installed) echo "❌ Version go$arg1 not installed, please run go-install $arg1" ;;
                already_using) echo "✅ Already using go$arg1" ;;
                switch_success) echo "✅ Switched to Go $arg1 (current session only)" ;;
                switch_persisted) echo "✅ Switched to Go $arg1 (persisted, new terminals inherit)" ;;
                mirror_current) echo "Current mirror: $arg1" ;;
                mirror_usage) echo "Usage: go-mirror [URL]  no argument shows current mirror" ;;
                mirror_example) echo "Example: go-mirror https://mirrors.aliyun.com/golang" ;;
                mirror_set) echo "✅ Mirror set to: $arg1" ;;
                mirror_reload) echo "Please run source $arg1 or restart terminal to apply in current session" ;;
                arch_not_supported) echo "Unsupported architecture: $arg1" ;;
                existing_go_detected) echo "Existing Go installation detected" ;;
                existing_go_path) echo "Path" ;;
                existing_go_source) echo "Source" ;;
                existing_go_version) echo "Version" ;;
                existing_go_warn) echo "gv will use $arg1 as the install directory. Recommend uninstalling the existing Go to avoid conflicts" ;;
                existing_go_cleanup_brew) echo "Recommended: run 'brew uninstall go'" ;;
                existing_go_cleanup_system) echo "Recommended: remove directory $arg1" ;;
                existing_go_cleanup_path) echo "Recommended: remove the old Go path from PATH and shell config files" ;;
                existing_go_continue) echo "Continue installation? [Y/n]" ;;
                existing_go_abort) echo "Installation aborted" ;;
                old_config_detected) echo "Old Go configuration detected" ;;
                old_config_warn) echo "These settings may conflict with gv; recommend commenting out the relevant lines" ;;
                old_config_prompt) echo "Comment out these old config lines? [Y/n]" ;;
                old_config_commented) echo "✅ Old config commented out" ;;
                old_config_kept) echo "Old config left unchanged (handle manually if issues arise)" ;;
                vscode_hint) echo "Tip for VSCode users" ;;
                vscode_hint_detail) echo "Set in settings.json: \"go.goroot\": \"$arg1/go$arg2\"" ;;
                *) echo "Unknown message" ;;
            esac
            ;;
    esac
}
