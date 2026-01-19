#!/bin/bash
# 查詢 Authentication Users

# 載入環境變數
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
else
    echo "❌ 找不到 .env 檔案"
    exit 1
fi

# 執行查詢
dart run scripts/query_auth_users.dart
