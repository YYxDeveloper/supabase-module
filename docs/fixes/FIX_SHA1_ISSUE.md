# SHA-1 憑證指紋問題修復指南

## 🔴 發現的問題

### 當前 SHA-1 憑證指紋不一致

**本地 Debug Keystore 的 SHA-1:**
```
3F:60:9F:C0:A1:11:5D:0C:2B:8A:3C:C3:B9:7E:5F:79:26:07:C8:93
```

**您在 Google Cloud Console 中設定的 SHA-1:**
```
3F:60:9F:C0:A1:11:5D:0C:2B:8A:3C:C3:B9:7E:5F:79:26:07:C8:93
```

**❌ 兩個 SHA-1 不一致！這就是為什麼會出現 `Account reauth failed` 錯誤的原因。**

## 解決方案

### 方案 1: 在 Google Cloud Console 中新增正確的 SHA-1（推薦）

1. **前往 Google Cloud Console**
   - 訪問：https://console.cloud.google.com/apis/credentials?project=vigor-django-dev
   - 或使用專案編號：https://console.cloud.google.com/apis/credentials?project=794985788833

2. **編輯 Android OAuth 2.0 用戶端**
   - 找到類型為「Android」的 OAuth 2.0 用戶端 ID
   - 點擊編輯（鉛筆圖示）

3. **新增正確的 SHA-1 憑證指紋**
   - 在「SHA-1 憑證指紋」欄位中，新增：
     ```
     3F:60:9F:C0:A1:11:5D:0C:2B:8A:3C:C3:B9:7E:5F:79:26:07:C8:93
     ```
   - **保留**現有的 SHA-1（如果有的話），**新增**這個新的 SHA-1
   - 確認套件名稱為：`com.example.subabase_park`

4. **儲存變更**
   - 點擊「儲存」
   - 等待 5-10 分鐘讓變更生效

### 方案 2: 使用指定的 SHA-1 對應的 Keystore

如果您需要使用 `3F:60:9F:C0:A1:11:5D:0C:2B:8A:3C:C3:B9:7E:5F:79:26:07:C8:93` 這個 SHA-1，您需要：

1. **找到對應的 Keystore 檔案**
   - 這個 SHA-1 可能來自：
     - Release keystore
     - 另一個開發環境的 debug keystore
     - CI/CD 系統使用的 keystore

2. **使用該 Keystore 簽名應用程式**
   ```bash
   # 如果使用該 keystore，需要在 build.gradle.kts 中配置
   ```

## 驗證步驟

### 1. 確認本地 SHA-1
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android | grep SHA1
```

### 2. 確認 Google Cloud Console 設定
- 前往：https://console.cloud.google.com/apis/credentials?project=vigor-django-dev
- 或使用專案編號：https://console.cloud.google.com/apis/credentials?project=794985788833
- 檢查 Android OAuth 2.0 用戶端中的 SHA-1 列表
- 確認包含：`3F:60:9F:C0:A1:11:5D:0C:2B:8A:3C:C3:B9:7E:5F:79:26:07:C8:93`

### 3. 重新測試
- 等待 5-10 分鐘讓 Google Cloud Console 變更生效
- 重新執行應用程式
- 嘗試 Google Sign-In

## 當前配置摘要

### 應該在 Google Cloud Console 中設定的值

**Android OAuth 2.0 用戶端:**
- 套件名稱: `com.example.subabase_park`
- SHA-1 憑證指紋（Debug）: `3F:60:9F:C0:A1:11:5D:0C:2B:8A:3C:C3:B9:7E:5F:79:26:07:C8:93`
- SHA-1 憑證指紋（如果使用 Release）: `3F:60:9F:C0:A1:11:5D:0C:2B:8A:3C:C3:B9:7E:5F:79:26:07:C8:93`（如果有的話）

**Web OAuth 2.0 用戶端 ID:**
- `794985788833-4o2ctjvoenha3pq85qn6kkld57frtovk.apps.googleusercontent.com`

**iOS OAuth 2.0 用戶端 ID:**
- `794985788833-3vjtmctgom3ff9jnmu0pl4q4m0eig01m.apps.googleusercontent.com`

## 重要提醒

1. **Debug 和 Release 使用不同的 Keystore**
   - Debug keystore: `~/.android/debug.keystore`
   - Release keystore: 您自己創建的 keystore
   - 兩個 keystore 的 SHA-1 都應該在 Google Cloud Console 中設定

2. **多個 SHA-1 可以同時設定**
   - Google Cloud Console 允許在同一個 Android OAuth 用戶端中設定多個 SHA-1
   - 這樣可以同時支援 Debug 和 Release 版本

3. **變更生效時間**
   - Google Cloud Console 的變更需要 5-10 分鐘才能生效
   - 設定完成後請等待一段時間再測試

## 快速修復步驟

1. ✅ 確認本地 Debug SHA-1: `3F:60:9F:C0:A1:11:5D:0C:2B:8A:3C:C3:B9:7E:5F:79:26:07:C8:93`
2. 🔧 前往 Google Cloud Console 新增此 SHA-1
3. ⏱️ 等待 5-10 分鐘
4. 🧪 重新測試應用程式
