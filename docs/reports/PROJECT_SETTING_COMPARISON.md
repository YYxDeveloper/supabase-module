# Google Cloud 專案設定比較檢查清單

## 專案資訊

### 當前專案
- **專案 ID**: `vigor-django-dev`
- **專案編號**: `794985788833`

## 設定檢查清單

### 1. 專案基本資訊 ✅

| 項目 | 預期值 | 檢查狀態 |
|------|--------|----------|
| 專案 ID | `vigor-django-dev` | ⬜ 待檢查 |
| 專案編號 | `794985788833` | ⬜ 待檢查 |
| 專案狀態 | 啟用 | ⬜ 待檢查 |

**檢查方法：**
- Web UI: https://console.cloud.google.com/home/dashboard?project=vigor-django-dev
- CLI: `gcloud projects describe vigor-django-dev`

---

### 2. OAuth 同意畫面設定 ⚠️

| 項目 | 預期值 | 檢查狀態 |
|------|--------|----------|
| 使用者類型 | 外部或內部 | ⬜ 待檢查 |
| 應用程式名稱 | 已設定 | ⬜ 待檢查 |
| 使用者支援電子郵件 | 已設定 | ⬜ 待檢查 |
| 應用程式標誌 | 可選 | ⬜ 待檢查 |
| 授權網域 | 已設定 | ⬜ 待檢查 |
| 開發人員聯絡資訊 | 已設定 | ⬜ 待檢查 |

**檢查方法：**
- Web UI: https://console.cloud.google.com/apis/credentials/consent?project=vigor-django-dev
- CLI: `gcloud alpha iap oauth-brands list --project=vigor-django-dev`

---

### 3. OAuth 2.0 用戶端 ID 設定 🔑

#### Web 應用程式用戶端

| 項目 | 預期值 | 檢查狀態 |
|------|--------|----------|
| 用戶端 ID | `794985788833-4o2ctjvoenha3pq85qn6kkld57frtovk.apps.googleusercontent.com` | ⬜ 待檢查 |
| 已授權的 JavaScript 來源 | 已設定（如需要） | ⬜ 待檢查 |
| 已授權的重新導向 URI | 已設定（如需要） | ⬜ 待檢查 |

**檢查方法：**
- Web UI: https://console.cloud.google.com/apis/credentials?project=vigor-django-dev
- 查找類型為「網頁應用程式」的 OAuth 2.0 用戶端 ID

---

#### Android 應用程式用戶端

| 項目 | 預期值 | 檢查狀態 |
|------|--------|----------|
| 用戶端 ID | Android 類型 | ⬜ 待檢查 |
| 套件名稱 | `com.example.subabase_park` | ⬜ 待檢查 |
| SHA-1 憑證指紋 (Debug) | `3F:60:9F:C0:A1:11:5D:0C:2B:8A:3C:C3:B9:7E:5F:79:26:07:C8:93` | ⬜ 待檢查 |
| SHA-1 憑證指紋 (Release) | `3F:60:9F:C0:A1:11:5D:0C:2B:8A:3C:C3:B9:7E:5F:79:26:07:C8:93` | ⬜ 待檢查 |

**檢查方法：**
- Web UI: https://console.cloud.google.com/apis/credentials?project=vigor-django-dev
- 查找類型為「Android」的 OAuth 2.0 用戶端 ID
- 點擊編輯，檢查 SHA-1 憑證指紋列表

**驗證本地 SHA-1：**
```bash
# Debug keystore
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android | grep SHA1
```

---

#### iOS 應用程式用戶端

| 項目 | 預期值 | 檢查狀態 |
|------|--------|----------|
| 用戶端 ID | `794985788833-3vjtmctgom3ff9jnmu0pl4q4m0eig01m.apps.googleusercontent.com` | ⬜ 待檢查 |
| Bundle ID | 與 iOS 專案一致 | ⬜ 待檢查 |

**檢查方法：**
- Web UI: https://console.cloud.google.com/apis/credentials?project=vigor-django-dev
- 查找類型為「iOS」的 OAuth 2.0 用戶端 ID

---

### 4. 已啟用的 API 📚

| API | 狀態 | 檢查狀態 |
|-----|------|----------|
| Google Sign-In API | 已啟用 | ⬜ 待檢查 |
| Identity Platform API | 已啟用（如使用 Supabase） | ⬜ 待檢查 |

**檢查方法：**
- Web UI: https://console.cloud.google.com/apis/library?project=vigor-django-dev
- CLI: `gcloud services list --enabled --project=vigor-django-dev`

**啟用 API（如需要）：**
```bash
gcloud services enable identitytoolkit.googleapis.com --project=vigor-django-dev
```

---

### 5. 應用程式設定（Flutter） 📱

| 項目 | 預期值 | 檢查狀態 |
|------|--------|----------|
| Web Client ID | `794985788833-4o2ctjvoenha3pq85qn6kkld57frtovk.apps.googleusercontent.com` | ✅ 已設定 |
| Android Server Client ID | `794985788833-4o2ctjvoenha3pq85qn6kkld57frtovk.apps.googleusercontent.com` | ✅ 已設定 |
| iOS Client ID | `794985788833-3vjtmctgom3ff9jnmu0pl4q4m0eig01m.apps.googleusercontent.com` | ✅ 已設定 |
| Android Package Name | `com.example.subabase_park` | ✅ 已設定 |

**檢查位置：**
- `lib/main.dart` - Google Sign-In 初始化
- `ios/Runner/Info.plist` - iOS GIDClientID

---

## 快速檢查步驟

### 使用 Web UI（推薦）

1. **登入 Google Cloud Console**
   ```
   https://console.cloud.google.com/?project=vigor-django-dev
   ```

2. **檢查 OAuth 憑證**
   ```
   https://console.cloud.google.com/apis/credentials?project=vigor-django-dev
   ```
   - 確認所有 OAuth 2.0 用戶端 ID 存在
   - 檢查 Android 用戶端的 SHA-1 憑證指紋
   - 確認套件名稱正確

3. **檢查 OAuth 同意畫面**
   ```
   https://console.cloud.google.com/apis/credentials/consent?project=vigor-django-dev
   ```
   - 確認已設定必要資訊

4. **檢查已啟用的 API**
   ```
   https://console.cloud.google.com/apis/library?project=vigor-django-dev
   ```
   - 搜尋 "Google Sign-In" 或 "Identity"
   - 確認相關 API 已啟用

### 使用 gcloud CLI

```bash
# 1. 安裝 gcloud CLI（如未安裝）
brew install --cask google-cloud-sdk

# 2. 登入
gcloud auth login

# 3. 設定專案
gcloud config set project vigor-django-dev

# 4. 檢查專案資訊
gcloud projects describe vigor-django-dev

# 5. 檢查已啟用的 API
gcloud services list --enabled --project=vigor-django-dev

# 6. 執行檢查腳本
bash check_project_setting.sh
```

---

## 常見問題排查

### Q1: 找不到 OAuth 2.0 用戶端 ID
**解決方法：**
- 確認在正確的專案中（vigor-django-dev）
- 檢查是否已創建 OAuth 2.0 用戶端
- 確認有適當的權限

### Q2: SHA-1 憑證指紋不匹配
**解決方法：**
- 確認本地 keystore 的 SHA-1
- 在 Google Cloud Console 中新增正確的 SHA-1
- 等待 5-10 分鐘讓變更生效

### Q3: API 未啟用
**解決方法：**
- 前往 API 庫頁面啟用相關 API
- 或使用 CLI: `gcloud services enable <api-name> --project=vigor-django-dev`

### Q4: OAuth 同意畫面未設定
**解決方法：**
- 前往 OAuth 同意畫面設定頁面
- 完成必要的設定（應用程式名稱、支援電子郵件等）

---

## 設定完成檢查

完成所有檢查後，應該確認：

- ✅ 專案 ID 正確：`vigor-django-dev`
- ✅ OAuth 同意畫面已設定
- ✅ Web OAuth 用戶端 ID 存在
- ✅ Android OAuth 用戶端 ID 存在且 SHA-1 正確
- ✅ iOS OAuth 用戶端 ID 存在
- ✅ 相關 API 已啟用
- ✅ Flutter 應用程式中的設定正確

---

## 下一步

1. 完成上述檢查清單
2. 修正任何不一致的設定
3. 等待 Google Cloud Console 變更生效（5-10 分鐘）
4. 重新測試 Google Sign-In 功能
