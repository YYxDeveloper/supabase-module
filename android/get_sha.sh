#!/bin/bash

# Android SHA 指紋取得腳本
# 用於取得 Debug 和 Release keystore 的 SHA 指紋

echo "=========================================="
echo "Android SHA 指紋檢查工具"
echo "=========================================="
echo ""

# Debug Keystore
DEBUG_KEYSTORE="$HOME/.android/debug.keystore"

if [ -f "$DEBUG_KEYSTORE" ]; then
    echo "✅ Debug Keystore 找到"
    echo "位置: $DEBUG_KEYSTORE"
    echo ""
    
    echo "SHA-1:"
    SHA1=$(keytool -list -v -keystore "$DEBUG_KEYSTORE" -alias androiddebugkey -storepass android -keypass android 2>/dev/null | grep SHA1 | sed 's/.*SHA1: //')
    if [ -n "$SHA1" ]; then
        echo "   $SHA1"
    else
        echo "   ❌ 無法讀取"
    fi
    
    echo ""
    echo "SHA-256:"
    SHA256=$(keytool -list -v -keystore "$DEBUG_KEYSTORE" -alias androiddebugkey -storepass android -keypass android 2>/dev/null | grep SHA256 | sed 's/.*SHA256: //')
    if [ -n "$SHA256" ]; then
        echo "   $SHA256"
    else
        echo "   ❌ 無法讀取"
    fi
else
    echo "❌ Debug Keystore 未找到"
    echo "預期位置: $DEBUG_KEYSTORE"
fi

echo ""
echo "=========================================="
echo "Release Keystore"
echo "=========================================="
echo "如果您有 Release keystore，請執行："
echo ""
echo "keytool -list -v -keystore <path-to-keystore> -alias <alias-name>"
echo ""
echo "範例："
echo "keytool -list -v -keystore android/app/release.keystore -alias release-key-alias"
echo ""
