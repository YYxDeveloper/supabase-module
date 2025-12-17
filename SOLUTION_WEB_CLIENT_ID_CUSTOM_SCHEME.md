# Web Client ID 不支援 Custom Scheme 的解決方案

## ⚠️ 問題說明

當嘗試在 Google Cloud Console 的 **Web OAuth Client ID** 中添加 iOS custom scheme URI 時：
```
com.googleusercontent.apps.794985788833-4o2ctjvoenha3pq85qn6kkld57frtovk:/
```

會出現錯誤：
```
重新導向無效：必須使用 HTTP 或 HTTPS 通訊協定
```

**原因：**
- Web OAuth Client ID **不支援** custom scheme URI（如 `com.googleusercontent.apps.xxx:/`）
- Web Client ID 只接受 HTTP/HTTPS 協議的 URI
- Custom scheme 只能添加到 **iOS OAuth Client ID** 中

---

## 🔍 當前情況

### 應用程式配置
- **iOS GIDClientID**: `794985788833-4o2ctjvoenha3pq85qn6kkld57frtovk.apps.googleusercontent.com` (Web Client ID)
- **程式碼**: 所有平台使用 Web Client ID

### 問題
- iOS 需要使用 custom scheme 進行 OAuth 回調
- Web Client ID 不支援 custom scheme
- 但 Supabase 配置使用 Web Client ID，需要 ID Token 的 audience 匹配

---

## ✅ 解決方案

### **方案 1：使用 iOS Client ID（推薦）**

這是 Google Sign-In 的最佳實踐：iOS 應用程式應該使用 iOS Client ID。

#### 步驟 1：修改 iOS 配置

**修改 `ios/Runner/Info.plist`：**
```xml
<key>GIDClientID</key>
<string>794985788833-3vjtmctgom3ff9jnmu0pl4q4m0eig01m.apps.googleusercontent.com</string>
```

**修改 `ios/Runner/Info.plist` 的 URL Scheme：**
```xml
<key>CFBundleURLSchemes</key>
<array>
    <string>com.googleusercontent.apps.794985788833-3vjtmctgom3ff9jnmu0pl4q4m0eig01m</string>
</array>
```

#### 步驟 2：修改程式碼

**修改 `lib/main.dart`：**
```dart
if (Platform.isIOS) {
  // iOS 使用 iOS Client ID
  final iosClientId = '794985788833-3vjtmctgom3ff9jnmu0pl4q4m0eig01m.apps.googleusercontent.com';
  await GoogleSignIn.instance.initialize(
    clientId: iosClientId,
    serverClientId: webClientId, // serverClientId 仍使用 Web Client ID
  );
} else {
  // Android 和 Web 使用 Web Client ID
  await GoogleSignIn.instance.initialize(
    clientId: webClientId,
    serverClientId: webClientId,
  );
}
```

#### 步驟 3：在 Google Cloud Console 設定 iOS Client ID

1. 前往：https://console.cloud.google.com/apis/credentials?project=vigor-django-dev
2. 找到 **iOS OAuth Client ID**: `794985788833-3vjtmctgom3ff9jnmu0pl4q4m0eig01m`
3. 點擊「編輯」
4. 確認 **Bundle ID** 與 Xcode 專案中的 Bundle ID 一致
5. 儲存

#### 步驟 4：處理 Supabase Audience 驗證

**選項 A：在 Supabase 中配置多個 Client ID**
- 前往 Supabase Dashboard
- Authentication > Providers > Google
- 添加 iOS Client ID (`794985788833-3vjtmctgom3ff9jnmu0pl4q4m0eig01m`) 作為允許的 Client ID

**選項 B：修改後端驗證邏輯**
- 如果 Supabase 不支援多個 Client ID，可能需要修改後端驗證邏輯
- 在驗證 ID Token 時，同時接受 Web 和 iOS Client ID

---

### **方案 2：使用 Universal Links（進階）**

使用 HTTP/HTTPS URL 作為重新導向 URI，然後通過 Universal Links 轉發到應用程式。

**優點：**
- Web Client ID 支援 HTTP/HTTPS URI
- 不需要修改 Supabase 配置

**缺點：**
- 需要設定域名和 SSL 憑證
- 需要配置 Apple App Site Association 文件
- 設定較複雜

---

## 📋 推薦方案

**建議使用方案 1**，因為：
1. ✅ 符合 Google Sign-In 最佳實踐
2. ✅ iOS 應用程式應該使用 iOS Client ID
3. ✅ 不需要額外的基礎設施（如域名、SSL）
4. ✅ 設定相對簡單

---

## 🔧 實施步驟總結

1. **修改 `ios/Runner/Info.plist`**
   - `GIDClientID` → iOS Client ID
   - `CFBundleURLSchemes` → iOS Client ID 對應的 URL scheme

2. **修改 `lib/main.dart`**
   - iOS 平台使用 iOS Client ID
   - 其他平台使用 Web Client ID

3. **確認 Google Cloud Console**
   - iOS Client ID 的 Bundle ID 設定正確

4. **配置 Supabase**
   - 添加 iOS Client ID 到允許的 OAuth Client ID 列表
   - 或修改後端驗證邏輯

5. **測試**
   - 重新建置 iOS 應用程式
   - 測試 Google Sign-In 功能

---

## ⚠️ 注意事項

1. **ID Token Audience**
   - 使用 iOS Client ID 時，ID Token 的 audience 會是 iOS Client ID
   - 必須確保 Supabase 接受這個 audience

2. **設定生效時間**
   - Google Cloud Console 變更需要 5-10 分鐘生效
   - Supabase 設定變更通常立即生效

3. **測試**
   - 設定完成後，重新建置應用程式
   - 清除應用程式快取（如需要）
   - 測試完整的登入流程

---

## 🔗 相關連結

- Google Cloud Console: https://console.cloud.google.com/apis/credentials?project=vigor-django-dev
- Supabase Dashboard: 你的 Supabase 專案 Dashboard
- Google Sign-In iOS 文件: https://developers.google.com/identity/sign-in/ios
