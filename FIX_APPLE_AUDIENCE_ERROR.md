# 修正 Apple Sign-In Audience 錯誤

## 錯誤訊息

```
AuthApiException(message: Unacceptable audience in id_token: [com.example.subabasePark], statusCode: 400, code: null)
```

## 問題分析

### 【問題描述】
Apple ID token 的 `audience` 欄位與 Supabase 配置不匹配，導致 Supabase 拒絕該 token。

### 【問題成因分析】
1. **預設行為**：`sign_in_with_apple` 套件預設使用 **Bundle ID** (`com.example.subabasePark`) 作為 ID token 的 `audience`
2. **Supabase 驗證**：Supabase 的 Apple OAuth 驗證會檢查 ID token 中的 `audience` 是否與 Dashboard 中設定的 **Services ID** 一致
3. **不匹配情況**：
   - 如果 Supabase Dashboard 中設定的是 Services ID（例如：`com.example.subabase_park.signin`）
   - 但 ID token 的 audience 是 Bundle ID（`com.example.subabasePark`）
   - 就會出現此錯誤

### 【潛在風險】
- 使用者無法使用 Apple Sign-In 登入
- 認證流程中斷，影響使用者體驗
- 需要重新配置 Supabase 或修改程式碼

## 解決方案

### 方案 1：在 Supabase Dashboard 中使用 Bundle ID（推薦）

如果 Supabase 支援使用 Bundle ID 作為 Services ID，這是最簡單的解決方案。

**步驟：**
1. 登入 [Supabase Dashboard](https://app.supabase.com/)
2. 導航至 **Authentication** > **Providers** > **Apple**
3. 確認 **Services ID** 設定為：`com.example.subabasePark`（與 Bundle ID 一致）
4. 如果不同，請修改為 Bundle ID 或建立新的 Services ID

**優點：**
- 不需要修改程式碼
- 設定簡單

**缺點：**
- 需要確認 Supabase 是否支援使用 Bundle ID 作為 Services ID

### 方案 2：在程式碼中指定 Services ID（如果 Supabase 使用 Services ID）

如果 Supabase Dashboard 中設定的是 Services ID（例如：`com.example.subabase_park.signin`），則需要在程式碼中指定 `clientId`。

**步驟：**

1. **確認 Supabase Dashboard 中的 Services ID**
   - 登入 Supabase Dashboard
   - 查看 **Authentication** > **Providers** > **Apple** 中的 **Services ID**

2. **修改程式碼**

   在 `lib/main.dart` 的 `_signInWithApple()` 方法中，修改 `SignInWithApple.getAppleIDCredential` 呼叫：

   ```dart
   final credential = await SignInWithApple.getAppleIDCredential(
     scopes: [
       AppleIDAuthorizationScopes.email,
       AppleIDAuthorizationScopes.fullName,
     ],
     // 指定 Supabase Dashboard 中設定的 Services ID
     clientId: 'com.example.subabase_park.signin', // 替換為實際的 Services ID
   );
   ```

3. **確保 Apple Developer Console 設定正確**
   - 確認 Services ID 已正確設定
   - 確認 Services ID 的 Return URLs 包含 Supabase callback URL

**優點：**
- 符合 Supabase 的最佳實踐（使用 Services ID）
- 更靈活的配置

**缺點：**
- 需要修改程式碼
- 需要確認正確的 Services ID

### 方案 3：檢查並修正 Apple Developer Console 設定

確保 Apple Developer Console 中的設定與 Supabase 一致。

**步驟：**

1. **登入 Apple Developer Console**
   - 前往：https://developer.apple.com/account/
   - 導航至 **Certificates, Identifiers & Profiles** > **Identifiers**

2. **檢查 Services ID**
   - 找到你的 Services ID（例如：`com.example.subabase_park.signin`）
   - 確認 **Sign in with Apple** 已啟用
   - 確認 **Return URLs** 包含：
     ```
     https://<your-project-ref>.supabase.co/auth/v1/callback
     ```

3. **檢查 App ID**
   - 找到你的 App ID（Bundle ID：`com.example.subabasePark`）
   - 確認 **Sign in with Apple** capability 已啟用

4. **同步 Supabase Dashboard 設定**
   - 確保 Supabase Dashboard 中的 **Services ID** 與 Apple Developer Console 中的 Services ID 一致

## 診斷步驟

### 1. 檢查 Supabase Dashboard 設定

```bash
# 登入 Supabase Dashboard 並檢查：
# Authentication > Providers > Apple
# - Services ID: ?
# - Team ID: ?
# - Key ID: ?
```

### 2. 檢查 Apple Developer Console 設定

```bash
# 檢查：
# 1. Services ID 是否存在
# 2. Services ID 的 Return URLs 是否包含 Supabase callback
# 3. App ID (Bundle ID) 的 Sign in with Apple 是否啟用
```

### 3. 檢查程式碼中的 Bundle ID

```bash
# 檢查 iOS Bundle ID
grep -r "PRODUCT_BUNDLE_IDENTIFIER" ios/Runner.xcodeproj/project.pbxproj
```

### 4. 測試並查看錯誤訊息

執行應用程式並嘗試 Apple Sign-In，查看完整的錯誤訊息以確認 audience 值。

## 常見問題

### Q: 如何知道 Supabase 使用的是 Bundle ID 還是 Services ID？

A: 登入 Supabase Dashboard，查看 **Authentication** > **Providers** > **Apple** 中的 **Services ID** 欄位。如果該欄位顯示的是 Bundle ID，則使用方案 1；如果是其他值（例如 `com.example.subabase_park.signin`），則使用方案 2。

### Q: 可以同時支援 Bundle ID 和 Services ID 嗎？

A: 不行。Supabase 的 Apple OAuth 配置只能使用一個 Services ID。ID token 的 audience 必須與 Supabase 配置的 Services ID 完全一致。

### Q: 修改後需要重新編譯應用程式嗎？

A: 是的。如果修改了程式碼（方案 2），需要重新編譯並執行應用程式。如果只修改 Supabase Dashboard 設定（方案 1），通常不需要重新編譯，但建議重新測試。

## 相關文件

- [Supabase Apple Provider 文件](https://supabase.com/docs/guides/auth/social-login/auth-apple)
- [sign_in_with_apple 套件文件](https://pub.dev/packages/sign_in_with_apple)
- [Apple Sign In with Apple 文件](https://developer.apple.com/sign-in-with-apple/)

## 下一步

1. 確認 Supabase Dashboard 中的 Services ID 設定
2. 根據設定選擇適當的解決方案
3. 修改程式碼（如需要）
4. 重新測試 Apple Sign-In 功能
5. 確認錯誤已解決
