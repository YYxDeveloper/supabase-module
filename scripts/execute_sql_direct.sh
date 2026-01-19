#!/bin/bash

# 從 .env 載入環境變數
export $(cat .env | grep -v '^#' | xargs)

# 讀取 SQL 檔案
SQL_CONTENT=$(cat scripts/setup_rls_simple.sql)

echo "🔧 正在執行 RLS 設定 SQL..."
echo "📍 專案: dknjuzjbudprjrgdzaeo"
echo ""

# 使用 Supabase REST API 執行 SQL
# 注意：這需要使用 service_role key 或通過 Management API
# 由於安全限制，建議手動在 Dashboard 執行

echo "⚠️  由於安全限制，DDL 語句無法通過標準 API 執行。"
echo ""
echo "請手動執行以下步驟："
echo "1. 前往 https://supabase.com/dashboard/project/dknjuzjbudprjrgdzaeo/sql"
echo "2. 複製並執行以下 SQL："
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cat scripts/setup_rls_simple.sql
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "或者，直接在終端機執行:"
echo "  pbcopy < scripts/setup_rls_simple.sql"
echo "  # 然後前往 Dashboard 貼上執行"
