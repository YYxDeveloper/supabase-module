#!/bin/bash

# 快速停止所有 supabase_test 專案的容器
# 用於解決端口衝突問題

echo "🛑 正在停止所有 supabase_test 專案的容器..."
echo ""

CONTAINERS=$(docker ps --format "{{.Names}}" | grep supabase_test)

if [ -z "$CONTAINERS" ]; then
    echo "✅ 沒有找到運行中的 supabase_test 容器"
    exit 0
fi

STOPPED=0
FAILED=0

for container in $CONTAINERS; do
    echo "   正在停止: $container"
    if docker stop $container >/dev/null 2>&1; then
        echo "   ✅ 已停止: $container"
        STOPPED=$((STOPPED + 1))
    else
        echo "   ❌ 停止失敗: $container"
        FAILED=$((FAILED + 1))
    fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 結果統計："
echo "   ✅ 成功停止: $STOPPED 個容器"
if [ $FAILED -gt 0 ]; then
    echo "   ❌ 失敗: $FAILED 個容器"
fi
echo ""

if [ $STOPPED -gt 0 ]; then
    echo "✅ 端口衝突問題已解決"
    echo ""
    echo "現在可以嘗試啟動當前專案的 Supabase："
    echo "   supabase start"
else
    echo "⚠️  沒有成功停止任何容器"
fi


