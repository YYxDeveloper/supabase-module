# iOS URL Scheme 設定檢查報告

## 📋 檢查結果

### ✅ Info.plist 設定（正確）

**檔案**: `ios/Runner/Info.plist`

1. **GIDClientID**
   ```
   794985788833-3vjtmctgom3ff9jnmu0pl4q4m0eig01m.apps.googleusercontent.com
   ```
   ✅ 已正確設定

2. **CFBundleURLTypes**
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
   ✅ URL Scheme 已正確設定

### ⚠️ Xcode 專案設定（需要確認）

**檔案**: `ios/Runner.xcodeproj/project.pbxproj`

- ⚠️ 在 project.pbxproj 中未找到明確的 URL Types 設定
- 這可能需要在 Xcode 中手動設定 URL Types

### 📱 Bundle ID

**當前 Bundle ID**: `com.example.subabasePark`

**注意**: 此 Bundle ID 需要與 Google Cloud Console 中的 iOS OAuth 2.0 用戶端設定一致。

## 🔍 詳細檢查

### URL Scheme 格式驗證

**設定的 URL Scheme**: `com.googleusercontent.apps.794985788833-3vjtmctgom3ff9jnmu0pl4q4m0eig01m`

**對應的 Client ID**: `794985788833-3vjtmctgom3ff9jnmu0pl4q4m0eig01m.apps.googleusercontent.com`

✅ URL Scheme 格式正確（REVERSED_CLIENT_ID 格式）

### 設定對應關係

| 項目 | 值 | 狀態 |
|------|-----|------|
| GIDClientID | `794985788833-3vjtmctgom3ff9jnmu0pl4q4m0eig01m.apps.googleusercontent.com` | ✅ |
| URL Scheme | `com.googleusercontent.apps.794985788833-3vjtmctgom3ff9jnmu0pl4q4m0eig01m` | ✅ |
| Bundle ID | `com.example.subabasePark` | ⚠️ 需確認 |

## ⚠️ 發現的問題

### 問題 1: Xcode 專案設定中可能缺少 URL Types

**症狀**: 
- Info.plist 中已設定 URL scheme
- 但 Xcode 專案設定中可能未配置 URL Types
- 這可能導致應用程式無法識別 URL scheme

**解決方法**:
1. 開啟 Xcode: `open ios/Runner.xcodeproj`
2. 選擇 Runner target > Info 標籤
3. 在 URL Types 中新增 URL scheme
4. 設定 URL Schemes: `com.googleusercontent.apps.794985788833-3vjtmctgom3ff9jnmu0pl4q4m0eig01m`

### 問題 2: Bundle ID 可能需要確認

**當前 Bundle ID**: `com.example.subabasePark`

**需要確認**:
- 此 Bundle ID 是否與 Google Cloud Console 中的 iOS OAuth 2.0 用戶端設定一致
- 如果不一致，需要更新 Google Cloud Console 或 Xcode 專案設定

## 🔧 建議的修復步驟

### 步驟 1: 在 Xcode 中設定 URL Types

1. **開啟 Xcode 專案**
   ```bash
   open ios/Runner.xcodeproj
   ```

2. **選擇 Runner Target**
   - 左側專案導航器 > Runner 專案（藍色圖示）
   - 中間區域 > Runner target

3. **設定 URL Types**
   - 點擊「Info」標籤
   - 找到「URL Types」區塊
   - 如果沒有，點擊「+」新增
   - 設定：
     - **URL Schemes**: `com.googleusercontent.apps.794985788833-3vjtmctgom3ff9jnmu0pl4q4m0eig01m`
     - **Role**: `Editor`

4. **儲存專案** (Cmd+S)

### 步驟 2: 確認 Bundle ID

1. **在 Xcode 中檢查**
   - Runner target > General > Bundle Identifier
   - 當前值: `com.example.subabasePark`

2. **在 Google Cloud Console 中確認**
   - 前往: https://console.cloud.google.com/apis/credentials?project=vigor-django-dev
   - 找到 iOS OAuth 2.0 用戶端
   - 確認 Bundle ID 是否為 `com.example.subabasePark`

3. **如果不一致**
   - 更新 Google Cloud Console 中的 Bundle ID，或
   - 更新 Xcode 專案中的 Bundle ID

### 步驟 3: 清理並重新建置

```bash
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

## ✅ 檢查清單

- [x] Info.plist 中 GIDClientID 已設定
- [x] Info.plist 中 URL Scheme 已設定
- [ ] Xcode 專案設定中 URL Types 已設定（需要手動確認）
- [ ] Bundle ID 與 Google Cloud Console 一致（需要確認）
- [ ] 已清理並重新建置專案
- [ ] 已重新安裝應用程式

## 📝 總結

### 已正確設定的項目
1. ✅ Info.plist 中的 GIDClientID
2. ✅ Info.plist 中的 URL Scheme

### 需要完成的項目
1. ⚠️ 在 Xcode 中設定 URL Types（如果尚未設定）
2. ⚠️ 確認 Bundle ID 與 Google Cloud Console 一致
3. ⚠️ 清理並重新建置專案
4. ⚠️ 重新安裝應用程式

## 🔗 相關文件

- `FIX_IOS_URL_SCHEME.md` - 詳細修復指南
- `QUICK_FIX_IOS_URL_SCHEME.md` - 快速修復步驟
