# iOS URL Scheme 錯誤修復指南

## 🔴 錯誤訊息

```
PlatformException(google_sign_in, Your app is missing support for the following URL schemes: com.googleusercontent.apps.79498578...
```

## 問題原因

此錯誤表示 iOS 應用程式無法識別 Google Sign-In 所需的 URL scheme。雖然 `Info.plist` 中已設定 URL scheme，但可能需要在 Xcode 專案設定中也進行配置。

## 解決方案

### 方法 1: 在 Xcode 中手動設定（推薦）

1. **開啟 Xcode 專案**
   ```bash
   open ios/Runner.xcodeproj
   ```

2. **選擇 Runner Target**
   - 在左側專案導航器中，點擊 `Runner` 專案
   - 選擇 `Runner` target（不是專案）

3. **設定 URL Types**
   - 點擊頂部的「Info」標籤
   - 展開「URL Types」區塊
   - 如果沒有 URL Types，點擊「+」新增一個
   - 設定以下值：
     - **URL Schemes**: `com.googleusercontent.apps.794985788833-3vjtmctgom3ff9jnmu0pl4q4m0eig01m`
     - **Role**: `Editor`
     - **Identifier**: `GoogleSignIn`（或任何描述性名稱）

4. **清理並重新建置**
   - 在 Xcode 中：Product > Clean Build Folder (Shift+Cmd+K)
   - 重新建置專案

### 方法 2: 驗證 Info.plist 設定

確認 `ios/Runner/Info.plist` 中包含以下設定：

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.googleusercontent.apps.794985788833-3vjtmctgom3ff9jnmu0pl4q4m0eig01m</string>
        </array>
    </dict>
</array>
```

### 方法 3: 使用 Flutter 清理並重新建置

```bash
# 清理 Flutter 建置快取
flutter clean

# 重新取得依賴
flutter pub get

# 重新建置 iOS 專案
cd ios
pod deintegrate  # 如果使用 CocoaPods
pod install
cd ..

# 重新執行應用程式
flutter run
```

### 方法 4: 檢查 URL Scheme 格式

確認 URL scheme 格式正確：
- ✅ 正確格式: `com.googleusercontent.apps.794985788833-3vjtmctgom3ff9jnmu0pl4q4m0eig01m`
- ❌ 錯誤格式: 包含空格、特殊字符或格式不正確

## 當前設定

### Info.plist 設定
- **檔案**: `ios/Runner/Info.plist`
- **GIDClientID**: `794985788833-3vjtmctgom3ff9jnmu0pl4q4m0eig01m.apps.googleusercontent.com`
- **URL Scheme**: `com.googleusercontent.apps.794985788833-3vjtmctgom3ff9jnmu0pl4q4m0eig01m`

### 需要確認的項目

1. ✅ Info.plist 中已設定 URL scheme
2. ⬜ Xcode 專案設定中已設定 URL Types
3. ⬜ 已清理並重新建置專案
4. ⬜ Bundle ID 與 Google Cloud Console 中的設定一致

## 驗證步驟

### 1. 檢查 Info.plist
```bash
grep -A 5 "CFBundleURLSchemes" ios/Runner/Info.plist
```

應該看到：
```xml
<key>CFBundleURLSchemes</key>
<array>
    <string>com.googleusercontent.apps.794985788833-3vjtmctgom3ff9jnmu0pl4q4m0eig01m</string>
</array>
```

### 2. 檢查 Xcode 專案設定
- 開啟 Xcode
- 檢查 Runner target 的 Info 標籤
- 確認 URL Types 中包含正確的 URL scheme

### 3. 測試 URL Scheme
在終端機中測試 URL scheme 是否註冊：
```bash
# 這會嘗試開啟應用程式（如果已安裝）
xcrun simctl openurl booted "com.googleusercontent.apps.794985788833-3vjtmctgom3ff9jnmu0pl4q4m0eig01m://"
```

## 常見問題

### Q1: 為什麼 Info.plist 設定了還是不行？
**A**: 有時需要在 Xcode 專案設定中也配置 URL Types，特別是當使用 Flutter 時。

### Q2: URL scheme 太長會有問題嗎？
**A**: URL scheme 長度通常不是問題，但確保格式正確很重要。

### Q3: 需要重新安裝應用程式嗎？
**A**: 是的，修改 URL scheme 後需要重新安裝應用程式才能生效。

### Q4: 模擬器和實體裝置都需要設定嗎？
**A**: 是的，兩者都需要正確設定。

## 完整修復步驟

1. ✅ 確認 Info.plist 設定正確
2. 🔧 在 Xcode 中設定 URL Types
3. 🧹 清理建置快取
4. 🔨 重新建置專案
5. 📱 重新安裝應用程式
6. 🧪 測試 Google Sign-In

## 如果問題仍然存在

1. 檢查 Bundle ID 是否與 Google Cloud Console 中的設定一致
2. 確認 iOS OAuth 2.0 用戶端 ID 已正確設定
3. 檢查是否有其他 URL scheme 衝突
4. 查看完整的錯誤日誌以獲取更多資訊
