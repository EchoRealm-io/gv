#!/bin/bash
# ==================== Internationalization (i18n) ====================

detect_lang() {
    local lang="${LANG:-$LC_ALL}"
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
                *) echo "Unknown message" ;;
            esac
            ;;
    esac
}
