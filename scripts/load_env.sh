#!/bin/bash
# 載入 .env 檔案並執行 Dart 腳本

# 讀取 .env 檔案並匯出環境變數
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
    echo "✅ 已載入 .env 檔案"
else
    echo "❌ 找不到 .env 檔案"
    exit 1
fi

# 執行 Dart 腳本
dart run scripts/check_users_count.dart
