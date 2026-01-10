# Apple Sign-In 設定指南

## 概述

本專案已實作 Apple Sign-In 功能，使用 Supabase 作為後端認證服務。

## 已完成的工作

### 1. 套件安裝
- ✅ 已安裝 `sign_in_with_apple: ^6.1.3` 套件
- ✅ 已安裝 `supabase_flutter: ^2.10.3` 套件

### 2. iOS 設定
- ✅ `ios/Runner/Runner.entitlements` 已設定 Apple Sign-In capability
- ✅ Xcode 專案已正確連結 entitlements 檔案

### 3. 程式碼實作
- ✅ 已實作 `_signInWithApple()` 方法
- ✅ 整合 Supabase Apple OAuth 認證
- ✅ 錯誤處理與使用者回饋機制
- ✅ 支援 iOS 和 macOS 平台

## Supabase Dashboard 設定步驟

### 1. 啟用 Apple Provider

1. 登入 [Supabase Dashboard](https://app.supabase.com/)
2. 選擇你的專案
3. 導航至 **Authentication** > **Providers**
4. 找到 **Apple** provider 並啟用它

### 2. 設定 Apple OAuth

在 Supabase Dashboard 的 Apple provider 設定中，你需要：

#### 取得 Apple 服務 ID 和密鑰

1. **登入 Apple Developer Console**
   - 前往：https://developer.apple.com/account/
   - 選擇你的 App ID

2. **建立 Services ID**
   - 導航至 **Certificates, Identifiers & Profiles** > **Identifiers**
   - 點擊 **+** 建立新的 Identifier
   - 選擇 **Services IDs** 類型
   - 填寫描述和 Identifier（例如：`com.example.subabase_park.signin`）
   - 啟用 **Sign in with Apple** 功能
   - 設定 **Return URLs**：
     ```
     https://<your-project-ref>.supabase.co/auth/v1/callback
     ```
     將 `<your-project-ref>` 替換為你的 Supabase 專案參考 ID

3. **建立 Key**
   - 導航至 **Keys**
   - 點擊 **+** 建立新的 Key
   - 填寫 Key Name
   - 啟用 **Sign in with Apple**
   - 下載 Key 檔案（`.p8` 檔案，只能下載一次）
   - 記下 **Key ID**

4. **在 Supabase Dashboard 中設定**
   - **Services ID**: 你建立的 Services ID（例如：`com.example.subabase_park.signin`）
   - **Team ID**: 你的 Apple Developer Team ID（可在 Apple Developer 帳號頁面找到）
   - **Key ID**: 剛才建立的 Key ID
   - **Private Key**: 上傳下載的 `.p8` 檔案內容

### 3. 設定 Redirect URL

在 Supabase Dashboard 的 **Authentication** > **URL Configuration** 中：

- **Site URL**: 你的應用程式 URL
- **Redirect URLs**: 確保包含：
  ```
  https://<your-project-ref>.supabase.co/auth/v1/callback
  ```

## 使用方式

### 在應用程式中使用

Apple Sign-In 按鈕已經在應用程式中實作。使用者點擊 "Sign in with Apple" 按鈕後：

1. 系統會顯示 Apple 登入對話框
2. 使用者使用 Face ID、Touch ID 或密碼進行認證
3. 應用程式會取得 Apple ID Token
4. Token 會傳送到 Supabase 進行驗證
5. 登入成功後，使用者資訊會顯示在畫面上

### 程式碼位置

- 主要實作：`lib/main.dart` 中的 `_signInWithApple()` 方法
- UI 按鈕：`lib/main.dart` 中的 `ElevatedButton.icon`（Apple Sign-In）

## 平台支援

- ✅ **iOS**: 完全支援
- ✅ **macOS**: 完全支援
- ⚠️ **Android**: 不支援（Apple Sign-In 僅限 Apple 平台）
- ⚠️ **Web**: 不支援（需要額外設定）

## 注意事項

1. **Apple Developer 帳號**: 需要有效的 Apple Developer 帳號（年費 $99 USD）
2. **測試環境**: 在模擬器上測試時，需要使用已登入 iCloud 的 Apple ID
3. **首次登入**: Apple 可能只在首次登入時提供使用者的姓名和電子郵件
4. **隱私**: Apple 可能會隱藏使用者的電子郵件，提供一個代理電子郵件地址

## 錯誤處理

應用程式已實作完整的錯誤處理機制：

- **取消登入**: 顯示橙色提示訊息
- **授權失敗**: 顯示紅色錯誤訊息
- **網路錯誤**: 顯示相應的錯誤訊息
- **其他錯誤**: 顯示詳細的錯誤資訊

## 常見問題

### Q: 為什麼在 Android 上無法使用 Apple Sign-In？
A: Apple Sign-In 是 Apple 專有的服務，僅在 iOS、macOS、watchOS 和 tvOS 上可用。

### Q: 如何測試 Apple Sign-In？
A: 
1. 確保在真實的 iOS 裝置或已登入 iCloud 的模擬器上測試
2. 確保 Supabase Dashboard 中的 Apple provider 已正確設定
3. 確保 Apple Developer Console 中的 Services ID 和 Key 已正確設定

### Q: 為什麼 Apple 沒有提供使用者的電子郵件？
A: 這是 Apple 的隱私保護機制。使用者可以選擇隱藏真實電子郵件，Apple 會提供一個代理電子郵件地址。

## 相關文件

- [Supabase Apple Provider 文件](https://supabase.com/docs/guides/auth/social-login/auth-apple)
- [sign_in_with_apple 套件文件](https://pub.dev/packages/sign_in_with_apple)
- [Apple Sign In with Apple 文件](https://developer.apple.com/sign-in-with-apple/)
