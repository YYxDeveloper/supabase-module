#!/bin/bash

# Google Cloud 專案設定檢查腳本
# 專案 ID: vigor-django-dev
# 專案編號: 794985788833

echo "=========================================="
echo "Google Cloud 專案設定檢查"
echo "=========================================="
echo ""

# 檢查 gcloud CLI 是否安裝
if ! command -v gcloud &> /dev/null; then
    echo "❌ gcloud CLI 未安裝"
    echo ""
    echo "安裝方法："
    echo "  macOS: brew install --cask google-cloud-sdk"
    echo "  或訪問: https://cloud.google.com/sdk/docs/install"
    echo ""
    echo "請使用 Google Cloud Console Web UI 進行檢查："
    echo "  https://console.cloud.google.com/apis/credentials?project=vigor-django-dev"
    exit 1
fi

echo "✅ gcloud CLI 已安裝"
echo ""

# 檢查登入狀態
echo "=== 檢查登入狀態 ==="
gcloud auth list
echo ""

# 檢查當前專案
echo "=== 檢查當前專案 ==="
CURRENT_PROJECT=$(gcloud config get-value project 2>/dev/null)
echo "當前專案: ${CURRENT_PROJECT:-未設定}"
echo "預期專案 ID: vigor-django-dev"
echo "預期專案編號: 794985788833"
echo ""

if [ "$CURRENT_PROJECT" != "vigor-django-dev" ] && [ "$CURRENT_PROJECT" != "794985788833" ]; then
    echo "⚠️  當前專案與預期不符"
    echo "設定專案: gcloud config set project vigor-django-dev"
    echo ""
fi

# 檢查專案資訊
echo "=== 檢查專案資訊 ==="
gcloud projects describe vigor-django-dev 2>/dev/null || \
gcloud projects describe 794985788833 2>/dev/null || \
echo "無法取得專案資訊，請確認專案存在且有權限"
echo ""

# 檢查 OAuth 同意畫面
echo "=== 檢查 OAuth 同意畫面 ==="
gcloud alpha iap oauth-brands list --project=vigor-django-dev 2>/dev/null || \
echo "無法列出 OAuth brands（可能需要啟用 API 或使用 Web UI）"
echo ""

# 檢查已啟用的 API
echo "=== 檢查已啟用的 API ==="
echo "檢查 Google Sign-In 相關 API..."
gcloud services list --enabled --project=vigor-django-dev 2>/dev/null | grep -i "oauth\|identity\|sign" || \
echo "無法列出服務（請使用 Web UI 檢查）"
echo ""

echo "=========================================="
echo "建議使用 Web UI 進行詳細檢查："
echo "=========================================="
echo ""
echo "1. OAuth 憑證設定："
echo "   https://console.cloud.google.com/apis/credentials?project=vigor-django-dev"
echo ""
echo "2. OAuth 同意畫面："
echo "   https://console.cloud.google.com/apis/credentials/consent?project=vigor-django-dev"
echo ""
echo "3. 已啟用的 API："
echo "   https://console.cloud.google.com/apis/library?project=vigor-django-dev"
echo ""
