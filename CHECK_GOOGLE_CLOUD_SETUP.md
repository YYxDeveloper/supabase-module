# Google Cloud Console 設定檢查指南

## 使用 Google Cloud CLI 檢查設定

### 1. 安裝 Google Cloud SDK

#### macOS
```bash
# 使用 Homebrew 安裝
brew install --cask google-cloud-sdk

# 或下載安裝程式
# https://cloud.google.com/sdk/docs/install
```

#### 初始化 gcloud
```bash
gcloud init
```

### 2. 登入 Google Cloud
```bash
gcloud auth login
```

### 3. 設定專案
```bash
# 使用專案 ID（推薦）
gcloud config set project vigor-django-dev

# 或使用專案編號
# gcloud config set project 794985788833
```

### 4. 檢查 OAuth 2.0 用戶端 ID

#### 列出所有 OAuth 2.0 用戶端
```bash
# 使用專案 ID
gcloud alpha iap oauth-clients list --project=vigor-django-dev

# 或使用專案編號
# gcloud alpha iap oauth-clients list --project=794985788833
```

#### 或使用 REST API 檢查
```bash
# 需要先啟用 API
gcloud services enable iap.googleapis.com

# 列出 OAuth 用戶端（使用專案 ID）
curl -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  "https://iap.googleapis.com/v1/projects/vigor-django-dev/oauthClients"
```

### 5. 檢查憑證設定（使用 Google Cloud Console API）

由於 OAuth 用戶端設定通常需要透過 Console UI 或 API 檢查，建議使用以下方法：

#### 方法 1: 使用 Google Cloud Console Web UI
1. 前往：https://console.cloud.google.com/apis/credentials?project=vigor-django-dev
   - 或使用專案編號：https://console.cloud.google.com/apis/credentials?project=794985788833
2. 查看 OAuth 2.0 用戶端 ID 列表
3. 找到 Android 類型的用戶端 ID
4. 檢查 SHA-1 憑證指紋是否包含：
   ```
   3F:60:9F:C0:A1:11:5D:0C:2B:8A:3C:C3:B9:7E:5F:79:26:07:C8:93
   ```
   （Debug keystore 的 SHA-1）

#### 方法 2: 使用 REST API（需要適當權限）
```bash
# 獲取訪問令牌
ACCESS_TOKEN=$(gcloud auth print-access-token)

# 列出憑證（使用專案 ID，需要啟用 Cloud Resource Manager API）
curl -H "Authorization: Bearer $ACCESS_TOKEN" \
  "https://cloudresourcemanager.googleapis.com/v1/projects/vigor-django-dev"
```

## 當前應設定的值

### Android OAuth 2.0 用戶端設定
- **套件名稱**: `com.example.subabase_park`
- **SHA-1 憑證指紋**: `3F:60:9F:C0:A1:11:5D:0C:2B:8A:3C:C3:B9:7E:5F:79:26:07:C8:93`

### Web OAuth 2.0 用戶端 ID
- **Client ID**: `794985788833-4o2ctjvoenha3pq85qn6kkld57frtovk.apps.googleusercontent.com`

### iOS OAuth 2.0 用戶端 ID
- **Client ID**: `794985788833-3vjtmctgom3ff9jnmu0pl4q4m0eig01m.apps.googleusercontent.com`

## 手動檢查步驟（如果 CLI 不可用）

### 1. 登入 Google Cloud Console
- 前往：https://console.cloud.google.com/
- 選擇專案：
  - 專案 ID: `vigor-django-dev`
  - 專案編號: `794985788833`

### 2. 導航至憑證頁面
- 前往：「API 和服務」>「憑證」
- 或直接訪問：https://console.cloud.google.com/apis/credentials?project=vigor-django-dev
- 或使用專案編號：https://console.cloud.google.com/apis/credentials?project=794985788833

### 3. 檢查 Android OAuth 2.0 用戶端
- 在 OAuth 2.0 用戶端 ID 列表中，找到類型為「Android」的用戶端
- 點擊編輯，檢查以下項目：
  - ✅ 套件名稱是否為：`com.example.subabase_park`
  - ✅ SHA-1 憑證指紋是否包含：`3F:60:9F:C0:A1:11:5D:0C:2B:8A:3C:C3:B9:7E:5F:79:26:07:C8:93`（Debug keystore）
  - ✅ SHA-1 憑證指紋是否包含：`3F:60:9F:C0:A1:11:5D:0C:2B:8A:3C:C3:B9:7E:5F:79:26:07:C8:93`（如果使用 Release keystore）

### 4. 檢查 Web OAuth 2.0 用戶端
- 找到類型為「網頁應用程式」的用戶端
- 確認 Client ID 為：`794985788833-4o2ctjvoenha3pq85qn6kkld57frtovk.apps.googleusercontent.com`

### 5. 檢查 iOS OAuth 2.0 用戶端
- 找到類型為「iOS」的用戶端
- 確認 Client ID 為：`794985788833-3vjtmctgom3ff9jnmu0pl4q4m0eig01m.apps.googleusercontent.com`

## 驗證 SHA-1 憑證指紋

### 檢查 Debug Keystore 的 SHA-1
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android | grep SHA1
```

### 應該看到類似輸出：
```
SHA1: 3F:60:9F:C0:A1:11:5D:0C:2B:8A:3C:C3:B9:7E:5F:79:26:07:C8:93
```

## 常見問題

### Q: 如何新增 SHA-1 憑證指紋？
A: 
1. 前往 Google Cloud Console > API 和服務 > 憑證
2. 點擊 Android OAuth 2.0 用戶端 ID
3. 在「SHA-1 憑證指紋」欄位中新增指紋
4. 儲存變更

### Q: 設定後多久生效？
A: 通常需要 5-10 分鐘讓變更生效

### Q: 如何確認設定是否正確？
A: 
1. 檢查 Google Cloud Console 中的設定
2. 重新執行應用程式
3. 查看應用程式日誌，確認錯誤訊息

## 快速檢查腳本

如果已安裝 gcloud CLI，可以執行：

```bash
#!/bin/bash
echo "=== 檢查 Google Cloud 專案設定 ==="
gcloud config get-value project

echo ""
echo "=== 檢查當前登入狀態 ==="
gcloud auth list

echo ""
echo "=== 檢查 OAuth 同意畫面 ==="
gcloud alpha iap oauth-brands list 2>/dev/null || echo "需要啟用 IAP API"

echo ""
echo "請前往以下網址手動檢查 OAuth 用戶端設定："
echo "專案 ID: https://console.cloud.google.com/apis/credentials?project=vigor-django-dev"
echo "專案編號: https://console.cloud.google.com/apis/credentials?project=794985788833"
```
