# 快速修正 Apple Sign-In Audience 錯誤

## 錯誤訊息
```
AuthApiException(message: Unacceptable audience in id_token: [com.example.subabasePark], statusCode: 400)
```

## 快速診斷

### 步驟 1：檢查 Supabase Dashboard 設定

1. 登入 [Supabase Dashboard](https://app.supabase.com/)
2. 導航至 **Authentication** > **Providers** > **Apple**
3. 查看 **Services ID** 欄位的值

### 步驟 2：根據設定選擇修正方案

#### ✅ 方案 A：Supabase Services ID = `com.example.subabasePark`（與 Bundle ID 一致）

**不需要修改程式碼！**

只需要確認：
- ✅ Supabase Dashboard 中的 Services ID 確實是 `com.example.subabasePark`
- ✅ Apple Developer Console 中的 Services ID 設定正確
- ✅ Services ID 的 Return URLs 包含 Supabase callback URL

如果設定正確但仍有錯誤，請檢查：
1. Apple Developer Console 中的 Services ID 是否啟用 "Sign in with Apple"
2. Return URLs 是否正確設定

#### ✅ 方案 B：Supabase Services ID ≠ Bundle ID（例如：`com.example.subabasePark.auth`）

**重要：`sign_in_with_apple` 套件不支援指定 `clientId` 參數！**

**解決方案：在 Supabase Dashboard 中將 Services ID 改為 Bundle ID**

1. **登入 Supabase Dashboard**
   - 前往：https://app.supabase.com/
   - 導航至 **Authentication** > **Providers** > **Apple**
   - 將 **Services ID** 從 `com.example.subabasePark.auth` 改為 `com.example.subabasePark`（與 Bundle ID 一致）

2. **更新 Apple Developer Console**
   - 確保 Services ID `com.example.subabasePark` 存在並已啟用 "Sign in with Apple"
   - 確認 Return URLs 包含 Supabase callback URL

3. **重新測試**

   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

**詳細說明請參考：`SOLUTION_APPLE_SERVICES_ID.md`**

## 專案設定值

根據你的專案設定：

- **Bundle ID**: `com.example.subabasePark`
- **Supabase Services ID**: `com.example.subabasePark.auth` ⚠️ 需要改為 Bundle ID

**重要**：`sign_in_with_apple` 套件在 iOS 上預設使用 Bundle ID 作為 audience，因此 Supabase Dashboard 中的 Services ID 必須與 Bundle ID 一致。

## 驗證步驟

修正後，請確認：

1. ✅ Supabase Dashboard 中的 Services ID 與程式碼中的 `clientId` 一致（如果指定了）
2. ✅ Apple Developer Console 中的 Services ID 設定正確
3. ✅ Services ID 的 Return URLs 包含：`https://<your-project-ref>.supabase.co/auth/v1/callback`
4. ✅ 重新執行應用程式並測試 Apple Sign-In

## 如果問題仍然存在

1. **檢查 Apple Developer Console**
   - 確認 Services ID 已啟用 "Sign in with Apple"
   - 確認 Return URLs 設定正確

2. **檢查 Supabase Dashboard**
   - 確認 Apple Provider 已啟用
   - 確認 Services ID、Team ID、Key ID 和 Private Key 都已正確設定

3. **查看詳細錯誤訊息**
   - 檢查完整的錯誤堆疊追蹤
   - 確認 audience 值是否與 Supabase 設定一致

## 相關文件

- 詳細說明：`FIX_APPLE_AUDIENCE_ERROR.md`
- [Supabase Apple Provider 文件](https://supabase.com/docs/guides/auth/social-login/auth-apple)
