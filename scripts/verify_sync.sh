#!/bin/bash

echo "🔄 驗證 Auth Users 同步狀態..."
echo ""

# 載入環境變數
export $(cat .env | grep -v '^#' | xargs)

echo "1️⃣ 查詢 auth.users 數量..."
dart run scripts/query_auth_direct.dart > /tmp/auth_count.txt 2>&1
AUTH_COUNT=$(grep "總用戶數:" /tmp/auth_count.txt | grep -oE '[0-9]+')
echo "   auth.users: $AUTH_COUNT 筆"

echo ""
echo "2️⃣ 查詢 chats.users 數量..."
dart run scripts/check_users_count.dart > /tmp/chats_count.txt 2>&1
CHATS_COUNT=$(grep "總用戶數:" /tmp/chats_count.txt | grep -oE '[0-9]+')
echo "   chats.users: $CHATS_COUNT 筆"

echo ""
echo "═══════════════════════════════════════"
if [ "$AUTH_COUNT" = "$CHATS_COUNT" ]; then
    echo "✅ 同步成功！兩個表格的用戶數量一致"
else
    echo "⚠️  用戶數量不一致"
    echo "   auth.users:  $AUTH_COUNT"
    echo "   chats.users: $CHATS_COUNT"
fi
echo "═══════════════════════════════════════"
