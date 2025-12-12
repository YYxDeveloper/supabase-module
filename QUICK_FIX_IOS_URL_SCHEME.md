# iOS URL Scheme 錯誤快速修復

## 🔴 錯誤訊息
```
PlatformException(google_sign_in, Your app is missing support for the following URL schemes: com.googleusercontent.apps.79498578...
```

## ✅ 當前設定狀態

### Info.plist 設定（已正確）
- **URL Scheme**: `com.googleusercontent.apps.794985788833-3vjtmctgom3ff9jnmu0pl4q4m0eig01m`
- **GIDClientID**: `794985788833-3vjtmctgom3ff9jnmu0pl4q4m0eig01m.apps.googleusercontent.com`

## 🔧 修復步驟

### 步驟 1: 在 Xcode 中設定 URL Types（必須）

1. **開啟 Xcode 專案**
   ```bash
   open ios/Runner.xcodeproj
   ```

2. **選擇 Runner Target**
   - 在左側專案導航器中，點擊 `Runner` 專案（藍色圖示）
   - 在中間區域選擇 `Runner` target（不是專案）

3. **設定 URL Types**
   - 點擊頂部的「Info」標籤
   - 向下滾動找到「URL Types」區塊
   - 如果沒有 URL Types，點擊左下角的「+」按鈕新增一個
   - 展開 URL Type，設定以下值：
     - **URL Schemes**: `com.googleusercontent.apps.794985788833-3vjtmctgom3ff9jnmu0pl4q4m0eig01m`
     - **Role**: `Editor`
     - **Identifier**: `GoogleSignIn`（可選，用於識別）

4. **儲存設定**
   - 按 `Cmd+S` 儲存專案

### 步驟 2: 清理並重新建置

```bash
# 在專案根目錄執行
cd /Users/qw/YYx/flutters/subabase_park

# 清理 Flutter 建置快取
flutter clean

# 重新取得依賴
flutter pub get

# 清理 iOS 建置
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..

# 重新執行應用程式
flutter run
```

### 步驟 3: 如果使用 Xcode 建置

1. 在 Xcode 中：**Product > Clean Build Folder** (Shift+Cmd+K)
2. 重新建置：**Product > Build** (Cmd+B)
3. 執行應用程式：**Product > Run** (Cmd+R)

## ⚠️ 重要提醒

1. **必須在 Xcode 中設定 URL Types**
   - 僅在 Info.plist 中設定可能不夠
   - Xcode 專案設定也需要配置

2. **重新安裝應用程式**
   - 修改 URL scheme 後，必須重新安裝應用程式
   - 刪除舊版本，然後重新安裝

3. **檢查 Bundle ID**
   - 確認 Bundle ID 與 Google Cloud Console 中的設定一致
   - 在 Xcode 中：Runner target > General > Bundle Identifier

## 驗證設定

### 檢查 Info.plist
```bash
grep -A 5 "CFBundleURLSchemes" ios/Runner/Info.plist
```

### 檢查 Xcode 專案設定
- 開啟 Xcode
- Runner target > Info > URL Types
- 確認 URL Scheme 已設定

## 如果問題仍然存在

1. **確認 Bundle ID 正確**
   - Xcode: Runner target > General > Bundle Identifier
   - Google Cloud Console: iOS OAuth 2.0 用戶端 > Bundle ID

2. **檢查是否有其他 URL scheme 衝突**
   - 確保沒有重複的 URL scheme

3. **完全重新建置**
   ```bash
   flutter clean
   rm -rf ios/Pods ios/Podfile.lock
   flutter pub get
   cd ios && pod install && cd ..
   flutter run
   ```

4. **檢查 Xcode 版本**
   - 確保使用最新版本的 Xcode
   - 更新 CocoaPods: `sudo gem install cocoapods`

## 常見問題

### Q: 為什麼 Info.plist 設定了還是不行？
**A**: Flutter 專案有時需要在 Xcode 專案設定中也配置 URL Types，這樣 Xcode 才能正確識別。

### Q: 需要重新安裝應用程式嗎？
**A**: 是的，修改 URL scheme 後必須重新安裝應用程式才能生效。

### Q: 模擬器和實體裝置都需要設定嗎？
**A**: 是的，兩者都需要正確設定，但設定一次即可同時適用於兩者。
