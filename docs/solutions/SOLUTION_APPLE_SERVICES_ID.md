# Apple Sign-In Services ID 問題解決方案

## 問題說明

- **Bundle ID**: `com.example.subabasePark`
- **Supabase Services ID**: `com.example.subabasePark.auth`
- **錯誤**: `sign_in_with_apple` 套件不支援指定 `clientId` 參數

## 根本原因

`sign_in_with_apple` 套件在 iOS 平台上**預設使用 Bundle ID** 作為 Apple ID token 的 `audience`。這個套件不提供 `clientId` 參數來指定不同的 Services ID。

## 解決方案

### ✅ 方案 1：在 Supabase Dashboard 中使用 Bundle ID（推薦）

**這是最簡單且推薦的解決方案。**

#### 步驟：

1. **登入 Supabase Dashboard**
   - 前往：https://app.supabase.com/
   - 選擇你的專案

2. **修改 Apple Provider 設定**
   - 導航至 **Authentication** > **Providers** > **Apple**
   - 將 **Services ID** 從 `com.example.subabasePark.auth` 改為 `com.example.subabasePark`（與 Bundle ID 一致）

3. **更新 Apple Developer Console**
   - 登入 [Apple Developer Console](https://developer.apple.com/account/)
   - 導航至 **Certificates, Identifiers & Profiles** > **Identifiers**
   - 找到 Services ID `com.example.subabasePark.auth`
   - 或者建立新的 Services ID `com.example.subabasePark`（如果不存在）
   - 確保 Services ID 已啟用 **Sign in with Apple**
   - 設定 **Return URLs**：
     ```
     https://<your-project-ref>.supabase.co/auth/v1/callback
     ```

4. **更新 Supabase Dashboard**
   - 在 Supabase Dashboard 的 Apple Provider 設定中，將 Services ID 更新為 `com.example.subabasePark`
   - 儲存設定

5. **測試**
   - 重新執行應用程式
   - 測試 Apple Sign-In 功能

#### 優點：
- ✅ 不需要修改程式碼
- ✅ 符合 `sign_in_with_apple` 套件的預設行為
- ✅ 設定簡單

#### 缺點：
- ⚠️ 需要修改 Supabase Dashboard 設定
- ⚠️ 可能需要更新 Apple Developer Console 設定

---

### ⚠️ 方案 2：使用原生 iOS 程式碼（不推薦）

如果你必須使用 Services ID (`com.example.subabasePark.auth`)，則需要使用原生 iOS 程式碼來實現 Apple Sign-In。

這需要：
1. 編寫原生 Swift/Objective-C 程式碼
2. 使用 Platform Channel 與 Flutter 通訊
3. 在原生程式碼中指定 Services ID

**不推薦此方案**，因為：
- 實作複雜
- 維護困難
- 不符合 Flutter 跨平台開發的理念

---

## 推薦做法

**強烈建議使用方案 1**：在 Supabase Dashboard 中將 Services ID 設定為 Bundle ID (`com.example.subabasePark`)。

這樣做的好處：
1. ✅ 符合 `sign_in_with_apple` 套件的預設行為
2. ✅ 不需要修改程式碼
3. ✅ 設定簡單，易於維護
4. ✅ 符合 Apple Sign-In 的最佳實踐（原生 iOS app 使用 Bundle ID）

## 驗證步驟

修正後，請確認：

1. ✅ Supabase Dashboard 中的 Services ID = `com.example.subabasePark`（與 Bundle ID 一致）
2. ✅ Apple Developer Console 中的 Services ID 設定正確
3. ✅ Services ID 的 Return URLs 包含 Supabase callback URL
4. ✅ 重新執行應用程式並測試 Apple Sign-In
5. ✅ 確認不再出現 "Unacceptable audience" 錯誤

## 相關文件

- [Supabase Apple Provider 文件](https://supabase.com/docs/guides/auth/social-login/auth-apple)
- [sign_in_with_apple 套件文件](https://pub.dev/packages/sign_in_with_apple)
- [Apple Sign In with Apple 文件](https://developer.apple.com/sign-in-with-apple/)
