#!/bin/bash

# 修復 Supabase Docker 端口衝突問題
# 檢測並修復 supabase_test 專案佔用的端口

echo "🔍 檢查 Supabase 常用端口佔用情況..."
echo ""

# Supabase 預設使用的端口範圍
PORTS=(54321 54322 54323 54324 54325 54326 54327)
CONFLICT_PORTS=()

for port in "${PORTS[@]}"; do
    if lsof -i :$port >/dev/null 2>&1; then
        OCCUPIER=$(lsof -i :$port | grep LISTEN | awk '{print $1}' | head -1)
        CONTAINER=$(docker ps --format "{{.Names}}" | grep supabase | xargs -I {} sh -c "docker port {} 2>/dev/null | grep -q ':$port' && echo {}" | head -1)
        CONFLICT_PORTS+=($port)
        echo "⚠️  端口 $port 已被佔用"
        if [ -n "$CONTAINER" ]; then
            echo "   佔用容器: $CONTAINER"
        else
            echo "   佔用程序: $OCCUPIER"
        fi
    fi
done

if [ ${#CONFLICT_PORTS[@]} -eq 0 ]; then
    echo "✅ 所有 Supabase 常用端口都可用"
    echo ""
fi

# 檢查 Docker 容器
echo ""
echo "📦 檢查 Supabase Docker 容器..."
CONTAINERS=$(docker ps -a | grep supabase | wc -l)
if [ "$CONTAINERS" -gt 0 ]; then
    echo "   找到 $CONTAINERS 個 Supabase 相關容器"
    echo ""
    
    # 檢查 supabase_test 專案的容器
    TEST_CONTAINERS=$(docker ps --format "{{.Names}}" | grep supabase_test | wc -l)
    if [ "$TEST_CONTAINERS" -gt 0 ]; then
        echo "   ⚠️  發現 $TEST_CONTAINERS 個 supabase_test 專案的容器正在運行："
        docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep supabase_test
        echo ""
    fi
    
    echo "   所有 Supabase 容器："
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep supabase | head -10
    echo ""
fi

if [ ${#CONFLICT_PORTS[@]} -gt 0 ] || [ "$TEST_CONTAINERS" -gt 0 ]; then
    echo "💡 解決方案選項："
    echo ""
    echo "【方案 1】停止整個 supabase_test 專案（推薦，最徹底）"
    echo "   一次性停止所有 supabase_test 專案的容器"
    echo ""
    echo "【方案 2】停止特定佔用端口的容器"
    echo "   只停止佔用衝突端口的容器"
    echo ""
    echo "【方案 3】前往 supabase_test 專案目錄執行 supabase stop"
    echo "   使用 Supabase CLI 正確停止專案"
    echo ""
    echo "【方案 4】修改當前專案的端口配置"
    echo "   如果兩個專案都需要運行，需要修改端口配置"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    read -p "請選擇方案 (1/2/3/4) 或按 Enter 退出: " choice

    case $choice in
        1)
            echo ""
            echo "🛑 正在停止所有 supabase_test 專案的容器..."
            STOPPED=0
            for container in $(docker ps --format "{{.Names}}" | grep supabase_test); do
                docker stop $container >/dev/null 2>&1
                if [ $? -eq 0 ]; then
                    echo "   ✅ 已停止: $container"
                    STOPPED=$((STOPPED + 1))
                else
                    echo "   ❌ 停止失敗: $container"
                fi
            done
            echo ""
            if [ $STOPPED -gt 0 ]; then
                echo "✅ 已停止 $STOPPED 個容器"
                echo ""
                echo "現在可以嘗試啟動當前專案的 Supabase："
                echo "   supabase start"
            else
                echo "⚠️  沒有找到需要停止的容器"
            fi
            ;;
        2)
            echo ""
            echo "🛑 正在停止佔用端口的容器..."
            STOPPED=0
            for port in "${CONFLICT_PORTS[@]}"; do
                CONTAINER=$(docker ps --format "{{.Names}}" | grep supabase_test | xargs -I {} sh -c "docker port {} 2>/dev/null | grep -q ':$port' && echo {}" | head -1)
                if [ -n "$CONTAINER" ]; then
                    docker stop $CONTAINER >/dev/null 2>&1
                    if [ $? -eq 0 ]; then
                        echo "   ✅ 已停止端口 $port 的容器: $CONTAINER"
                        STOPPED=$((STOPPED + 1))
                    fi
                fi
            done
            echo ""
            if [ $STOPPED -gt 0 ]; then
                echo "✅ 已停止 $STOPPED 個容器"
                echo ""
                echo "現在可以嘗試啟動當前專案的 Supabase："
                echo "   supabase start"
            else
                echo "⚠️  無法自動識別佔用端口的容器，建議使用方案 1"
            fi
            ;;
        3)
            echo ""
            echo "📍 請前往 supabase_test 專案目錄執行："
            echo "   cd <supabase_test專案路徑>"
            echo "   supabase stop"
            echo ""
            echo "或者告訴我 supabase_test 專案的路徑，我可以幫您停止"
            ;;
        4)
            echo ""
            echo "📝 需要先初始化 Supabase 專案："
            echo "   supabase init"
            echo ""
            echo "然後修改 supabase/config.toml 中的端口配置"
            echo "將相關端口改為其他未使用的端口（例如 54330-54337）"
            echo ""
            echo "需要修改的端口配置包括："
            echo "  - [db].port"
            echo "  - [studio].port"
            echo "  - [analytics].port"
            echo "  - [inbucket].port"
            echo "  - [kong].port"
            ;;
        *)
            echo ""
            echo "已取消操作"
            ;;
    esac
else
    echo "✅ 沒有發現端口衝突問題"
    echo ""
    echo "可以嘗試啟動 Supabase："
    echo "   supabase start"
fi

