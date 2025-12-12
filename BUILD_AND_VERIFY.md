# 建置與驗證步驟

## ✅ 已完成的步驟

### 步驟 1: 清理 Flutter 建置快取
```bash
flutter clean
```
✅ 已完成

### 步驟 2: 重新取得依賴
```bash
flutter pub get
```
✅ 已完成

### 步驟 3: 清理並重新安裝 CocoaPods
```bash
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
```
✅ 已完成

### 步驟 4: 檢查 Bundle ID

**當前 Bundle ID**: `com.example.subabasePark`

**需要確認**: 此 Bundle ID 必須與 Google Cloud Console 中的 iOS OAuth 2.0 用戶端設定一致。

## 📋 Bundle ID 驗證步驟

### 1. 檢查 Google Cloud Console

前往：https://console.cloud.google.com/apis/credentials?project=vigor-django-dev

1. 找到 iOS 類型的 OAuth 2.0 用戶端 ID
2. 檢查 Bundle ID 是否為：`com.example.subabasePark`
3. 如果不一致，需要：
   - 更新 Google Cloud Console 中的 Bundle ID，或
   - 更新 Xcode 專案中的 Bundle ID

### 2. 檢查 Xcode 專案設定

```bash
# 開啟 Xcode
open ios/Runner.xcodeproj
```

在 Xcode 中：
1. 選擇 Runner target
2. 點擊「General」標籤
3. 檢查「Bundle Identifier」是否為：`com.example.subabasePark`

## 🚀 下一步：重新執行應用程式

### 方法 1: 使用 Flutter CLI
```bash
flutter run
```

### 方法 2: 使用 Xcode
1. 開啟 Xcode: `open ios/Runner.xcodeproj`
2. 選擇目標裝置（模擬器或實體裝置）
3. 點擊「Run」按鈕（或按 Cmd+R）

## ⚠️ 重要提醒

### 重新安裝應用程式

修改 URL scheme 或 Bundle ID 後，必須：
1. **刪除舊版本應用程式**
   - 在模擬器/裝置上長按應用程式圖示
   - 選擇「刪除應用程式」

2. **重新安裝應用程式**
   - 使用 `flutter run` 或 Xcode 重新安裝

### 驗證 URL Scheme 是否生效

執行應用程式後，可以測試 URL scheme：

```bash
# 在模擬器上測試（如果應用程式已安裝）
xcrun simctl openurl booted "com.googleusercontent.apps.794985788833-3vjtmctgom3ff9jnmu0pl4q4m0eig01m://"
```

如果應用程式正確開啟，表示 URL scheme 已正確註冊。

## ✅ 檢查清單

- [x] 已清理 Flutter 建置快取
- [x] 已重新取得依賴
- [x] 已清理並重新安裝 CocoaPods
- [ ] Bundle ID 與 Google Cloud Console 一致（需確認）
- [ ] 已重新安裝應用程式
- [ ] 已測試 Google Sign-In 功能

## 🔗 相關連結

- **Google Cloud Console**: https://console.cloud.google.com/apis/credentials?project=vigor-django-dev
- **專案設定摘要**: `CURRENT_URL_SCHEME_STATUS.md`

## 📝 如果仍有錯誤

如果重新建置後仍有 URL scheme 錯誤：

1. **確認 Xcode 版本**
   - 確保使用最新版本的 Xcode
   - 更新 CocoaPods: `sudo gem install cocoapods`

2. **完全重新建置**
   ```bash
   flutter clean
   rm -rf ios/Pods ios/Podfile.lock
   flutter pub get
   cd ios && pod install && cd ..
   flutter run
   ```

3. **檢查 Xcode 專案設定**
   - 開啟 Xcode
   - 檢查 Runner target > Info > URL Types
   - 確認 URL scheme 已顯示

4. **查看完整錯誤日誌**
   - 在 Xcode 中查看完整錯誤訊息
   - 檢查是否有其他配置問題
