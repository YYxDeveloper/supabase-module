#!/bin/bash

# iOS 部署修復腳本
echo "🔧 開始修復 iOS 部署問題..."

# 1. 清理構建
echo "📦 清理 Flutter 構建..."
flutter clean

# 2. 獲取依賴
echo "📥 獲取 Flutter 依賴..."
flutter pub get

# 3. 清理 iOS 構建
echo "🍎 清理 iOS 構建..."
cd ios
rm -rf Pods
rm -rf Podfile.lock
rm -rf .symlinks
rm -rf Flutter/Flutter.framework
rm -rf Flutter/Flutter.podspec
rm -rf build

# 4. 重新安裝 Pods
echo "📦 重新安裝 CocoaPods..."
pod install --repo-update

cd ..

# 5. 檢查設備連接
echo "📱 檢查設備連接..."
flutter devices

echo ""
echo "✅ 修復步驟完成！"
echo ""
echo "📋 接下來請執行以下步驟："
echo "1. 確保 iPhone 已解鎖並信任此電腦"
echo "2. 在 iPhone 上：設定 > 一般 > VPN與裝置管理 > 信任開發者"
echo "3. 如果應用已安裝，請先刪除舊版本"
echo "4. 運行: flutter run -d <device-id>"
echo ""
echo "💡 如果問題仍然存在，請嘗試："
echo "   - 在 Xcode 中打開: open ios/Runner.xcworkspace"
echo "   - 選擇 Product > Clean Build Folder (Shift+Cmd+K)"
echo "   - 選擇 Product > Run (Cmd+R)"
