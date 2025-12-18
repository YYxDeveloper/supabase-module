#!/bin/bash

# Google Cloud OAuth 設定檢查與設定指南
# 專案: vigor-django-dev (794985788833)

echo "=========================================="
echo "Google Cloud OAuth 設定檢查與設定"
echo "=========================================="
echo ""

# 專案資訊
PROJECT_ID="vigor-django-dev"
PROJECT_NUMBER="794985788833"

# Client IDs
WEB_CLIENT_ID="794985788833-4o2ctjvoenha3pq85qn6kkld57frtovk.apps.googleusercontent.com"
IOS_CLIENT_ID="794985788833-3vjtmctgom3ff9jnmu0pl4q4m0eig01m.apps.googleusercontent.com"

# iOS URL Scheme（從 Web Client ID 轉換）
IOS_URL_SCHEME="com.googleusercontent.apps.794985788833-4o2ctjvoenha3pq85qn6kkld57frtovk"

# Android 設定
ANDROID_PACKAGE_NAME="com.example.subabase_park"
ANDROID_SHA1="3F:60:9F:C0:A1:11:5D:0C:2B:8A:3C:C3:B9:7E:5F:79:26:07:C8:93"

echo "📋 專案資訊"
echo "   專案 ID: $PROJECT_ID"
echo "   專案編號: $PROJECT_NUMBER"
echo ""

echo "📱 當前應用程式設定"
echo "   Web Client ID: $WEB_CLIENT_ID"
echo "   iOS Client ID: $IOS_CLIENT_ID"
echo "   iOS URL Scheme: $IOS_URL_SCHEME"
echo "   Android Package: $ANDROID_PACKAGE_NAME"
echo "   Android SHA-1: $ANDROID_SHA1"
echo ""

# 檢查 gcloud CLI
if command -v gcloud &> /dev/null; then
    echo "✅ gcloud CLI 已安裝"
    echo ""
    
    # 檢查登入狀態
    echo "=== 檢查 gcloud 登入狀態 ==="
    gcloud auth list
    echo ""
    
    # 檢查當前專案
    CURRENT_PROJECT=$(gcloud config get-value project 2>/dev/null)
    echo "當前專案: ${CURRENT_PROJECT:-未設定}"
    
    if [ "$CURRENT_PROJECT" != "$PROJECT_ID" ] && [ "$CURRENT_PROJECT" != "$PROJECT_NUMBER" ]; then
        echo "⚠️  設定專案..."
        gcloud config set project $PROJECT_ID 2>/dev/null || \
        gcloud config set project $PROJECT_NUMBER 2>/dev/null
        echo "✅ 專案已設定為: $(gcloud config get-value project)"
    fi
    echo ""
else
    echo "⚠️  gcloud CLI 未安裝"
    echo "   安裝方法: brew install --cask google-cloud-sdk"
    echo ""
fi

echo "=========================================="
echo "📝 Google Cloud Console 設定檢查清單"
echo "=========================================="
echo ""
echo "請前往以下網址進行設定："
echo "https://console.cloud.google.com/apis/credentials?project=$PROJECT_ID"
echo ""
echo ""

echo "1️⃣  Web OAuth 2.0 Client ID 設定"
echo "   Client ID: $WEB_CLIENT_ID"
echo "   ⚠️  重要：必須設定授權重定向 URI"
echo ""
echo "   需要添加的授權重定向 URI："
echo "   ✅ $IOS_URL_SCHEME:/"
echo "   ✅ $IOS_URL_SCHEME://"
echo ""
echo "   設定步驟："
echo "   1. 找到 Web Client ID ($WEB_CLIENT_ID)"
echo "   2. 點擊「編輯」"
echo "   3. 在「已授權的重新導向 URI」中新增："
echo "      - $IOS_URL_SCHEME:/"
echo "      - $IOS_URL_SCHEME://"
echo "   4. 儲存變更"
echo ""

echo "2️⃣  iOS OAuth 2.0 Client ID 設定（備用）"
echo "   Client ID: $IOS_CLIENT_ID"
echo "   Bundle ID: 請確認與 Xcode 專案中的 Bundle ID 一致"
echo ""

echo "3️⃣  Android OAuth 2.0 Client ID 設定"
echo "   套件名稱: $ANDROID_PACKAGE_NAME"
echo "   SHA-1 憑證指紋: $ANDROID_SHA1"
echo "   ⚠️  確認 SHA-1 已正確設定"
echo ""

echo "=========================================="
echo "🔧 快速設定指令（如果 gcloud 可用）"
echo "=========================================="
echo ""
echo "# 設定專案"
echo "gcloud config set project $PROJECT_ID"
echo ""
echo "# 啟用必要的 API"
echo "gcloud services enable oauth2.googleapis.com"
echo "gcloud services enable identitytoolkit.googleapis.com"
echo ""
echo "# 檢查 OAuth 用戶端（需要適當權限）"
echo "gcloud alpha iap oauth-clients list --project=$PROJECT_ID"
echo ""

echo "=========================================="
echo "📋 設定摘要"
echo "=========================================="
echo ""
echo "✅ 必須完成的設定："
echo "   1. Web Client ID 的授權重定向 URI 必須包含："
echo "      - $IOS_URL_SCHEME:/"
echo "      - $IOS_URL_SCHEME://"
echo ""
echo "   2. Android Client ID 的 SHA-1 必須包含："
echo "      - $ANDROID_SHA1"
echo ""
echo "⚠️  設定變更後需要 5-10 分鐘才會生效"
echo ""

echo "=========================================="
echo "🔗 快速連結"
echo "=========================================="
echo ""
echo "OAuth 憑證設定："
echo "https://console.cloud.google.com/apis/credentials?project=$PROJECT_ID"
echo ""
echo "OAuth 同意畫面："
echo "https://console.cloud.google.com/apis/credentials/consent?project=$PROJECT_ID"
echo ""
echo "API 庫："
echo "https://console.cloud.google.com/apis/library?project=$PROJECT_ID"
echo ""
