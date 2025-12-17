# Google Cloud OAuth 設定指南

## 📋 當前配置狀態

### 專案資訊
- **專案 ID**: `vigor-django-dev`
- **專案編號**: `794985788833`

### Client IDs
- **Web Client ID**: `794985788833-4o2ctjvoenha3pq85qn6kkld57frtovk.apps.googleusercontent.com`
- **iOS Client ID**: `794985788833-3vjtmctgom3ff9jnmu0pl4q4m0eig01m.apps.googleusercontent.com`（備用）

### iOS 設定
- **URL Scheme**: `com.googleusercontent.apps.794985788833-4o2ctjvoenha3pq85qn6kkld57frtovk`
- **GIDClientID**: `794985788833-4o2ctjvoenha3pq85qn6kkld57frtovk.apps.googleusercontent.com`

### Android 設定
- **Package Name**: `com.example.subabase_park`
- **SHA-1**: `3F:60:9F:C0:A1:11:5D:0C:2B:8A:3C:C3:B9:7E:5F:79:26:07:C8:93`

---

## ⚠️ 重要：必須完成的設定

### 1. Web Client ID 的授權重定向 URI

**問題**: iOS 應用程式使用 Web Client ID 進行登入，但 Web Client ID 預設不支援 iOS 的 custom scheme URL。

**解決方案**: 在 Google Cloud Console 中為 Web Client ID 添加 iOS URL scheme 作為授權重定向 URI。

#### 設定步驟：

1. **前往 Google Cloud Console**
   - 直接連結：https://console.cloud.google.com/apis/credentials?project=vigor-django-dev
   - 或使用專案編號：https://console.cloud.google.com/apis/credentials?project=794985788833

2. **找到 Web OAuth 2.0 Client ID**
   - Client ID: `794985788833-4o2ctjvoenha3pq85qn6kkld57frtovk.apps.googleusercontent.com`
   - 類型：網頁應用程式

3. **點擊「編輯」按鈕**

4. **在「已授權的重新導向 URI」區塊中，添加以下 URI：**
   ```
   com.googleusercontent.apps.794985788833-4o2ctjvoenha3pq85qn6kkld57frtovk:/
   com.googleusercontent.apps.794985788833-4o2ctjvoenha3pq85qn6kkld57frtovk://
   ```

5. **儲存變更**

#### 為什麼需要這個設定？

- iOS 應用程式使用 Web Client ID 進行登入（為了讓 ID Token 的 audience 與 Supabase 配置一致）
- iOS 登入流程使用 custom scheme URL 進行回調
- Web Client ID 預設不支援 custom scheme，必須手動添加

---

### 2. Android OAuth 2.0 Client ID 設定

#### 檢查項目：

1. **前往 OAuth 憑證頁面**
   - https://console.cloud.google.com/apis/credentials?project=vigor-django-dev

2. **找到 Android OAuth 2.0 Client ID**
   - 類型：Android

3. **確認以下設定：**
   - ✅ **套件名稱**: `com.example.subabase_park`
   - ✅ **SHA-1 憑證指紋**: 必須包含 `3F:60:9F:C0:A1:11:5D:0C:2B:8A:3C:C3:B9:7E:5F:79:26:07:C8:93`

4. **如果 SHA-1 未設定，請添加：**
   - 點擊「編輯」
   - 在「SHA-1 憑證指紋」欄位中添加：`3F:60:9F:C0:A1:11:5D:0C:2B:8A:3C:C3:B9:7E:5F:79:26:07:C8:93`
   - 儲存變更

---

### 3. iOS OAuth 2.0 Client ID 設定（備用）

雖然目前使用 Web Client ID，但建議保留 iOS Client ID 作為備用：

- **Client ID**: `794985788833-3vjtmctgom3ff9jnmu0pl4q4m0eig01m.apps.googleusercontent.com`
- **Bundle ID**: 請確認與 Xcode 專案中的 Bundle ID 一致

---

## 🔧 使用 gcloud CLI（可選）

如果已安裝 gcloud CLI，可以使用以下指令：

```bash
# 設定專案
gcloud config set project vigor-django-dev

# 啟用必要的 API
gcloud services enable oauth2.googleapis.com
gcloud services enable identitytoolkit.googleapis.com

# 檢查當前設定
gcloud config list
```

---

## 📝 設定檢查清單

完成設定後，請確認：

- [ ] Web Client ID 的授權重定向 URI 包含 iOS URL scheme
- [ ] Android Client ID 的 SHA-1 已正確設定
- [ ] 所有變更已儲存
- [ ] 等待 5-10 分鐘讓變更生效

---

## 🔗 快速連結

- **OAuth 憑證設定**: https://console.cloud.google.com/apis/credentials?project=vigor-django-dev
- **OAuth 同意畫面**: https://console.cloud.google.com/apis/credentials/consent?project=vigor-django-dev
- **API 庫**: https://console.cloud.google.com/apis/library?project=vigor-django-dev
- **專案總覽**: https://console.cloud.google.com/?project=vigor-django-dev

---

## ⏱️ 設定生效時間

設定變更後，通常需要 **5-10 分鐘** 才會生效。如果設定後立即測試失敗，請稍等片刻後再試。

---

## 🐛 常見問題

### Q: 為什麼 iOS 要使用 Web Client ID？

A: 因為 Supabase 的 Google OAuth 配置使用 Web Client ID。ID Token 的 `audience` 必須與 Supabase 配置的 Client ID 一致，否則會出現 "Unacceptable audience" 錯誤。

### Q: 設定後仍然出現錯誤？

A: 
1. 確認已正確儲存變更
2. 等待 5-10 分鐘讓變更生效
3. 重新建置並運行應用程式
4. 檢查應用程式日誌確認錯誤訊息

### Q: 如何確認設定是否正確？

A: 
1. 前往 Google Cloud Console 檢查設定
2. 確認授權重定向 URI 已正確添加
3. 重新運行應用程式測試登入功能
