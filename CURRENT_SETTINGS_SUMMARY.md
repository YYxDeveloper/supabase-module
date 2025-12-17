# 當前專案設定摘要

## 專案資訊

- **專案 ID**: `vigor-django-dev`
- **專案編號**: `794985788833`

## Flutter 應用程式設定

### Google Sign-In 設定 (`lib/main.dart`)

```dart
await GoogleSignIn.instance.initialize(
  clientId: '794985788833-4o2ctjvoenha3pq85qn6kkld57frtovk.apps.googleusercontent.com',
  serverClientId: '794985788833-4o2ctjvoenha3pq85qn6kkld57frtovk.apps.googleusercontent.com',
);
```

- **Web Client ID**: `794985788833-4o2ctjvoenha3pq85qn6kkld57frtovk.apps.googleusercontent.com`
- **Android Server Client ID**: `794985788833-4o2ctjvoenha3pq85qn6kkld57frtovk.apps.googleusercontent.com`

### Android 設定

**套件名稱** (`android/app/build.gradle.kts`):
```
com.example.subabase_park
```

**本地 Debug Keystore SHA-1**:
```
3F:60:9F:C0:A1:11:5D:0C:2B:8A:3C:C3:B9:7E:5F:79:26:07:C8:93
```

**設定的 SHA-1** (可能在 Release keystore):
```
3F:60:9F:C0:A1:11:5D:0C:2B:8A:3C:C3:B9:7E:5F:79:26:07:C8:93
```

### iOS 設定 (`ios/Runner/Info.plist`)

- **GIDClientID**: `794985788833-3vjtmctgom3ff9jnmu0pl4q4m0eig01m.apps.googleusercontent.com`

## 需要在 Google Cloud Console 中確認的設定

### 專案: vigor-django-dev (794985788833)

#### 1. OAuth 2.0 用戶端 ID 檢查清單

**Web 應用程式用戶端:**
- [ ] 用戶端 ID: `794985788833-4o2ctjvoenha3pq85qn6kkld57frtovk.apps.googleusercontent.com`
- [ ] 類型: 網頁應用程式
- [ ] 已授權的 JavaScript 來源（如需要）
- [ ] 已授權的重新導向 URI（如需要）

**Android 應用程式用戶端:**
- [ ] 類型: Android
- [ ] 套件名稱: `com.example.subabase_park`
- [ ] SHA-1 憑證指紋包含: `3F:60:9F:C0:A1:11:5D:0C:2B:8A:3C:C3:B9:7E:5F:79:26:07:C8:93` (Debug)
- [ ] SHA-1 憑證指紋包含: `3F:60:9F:C0:A1:11:5D:0C:2B:8A:3C:C3:B9:7E:5F:79:26:07:C8:93` (Release，如果使用)

**iOS 應用程式用戶端:**
- [ ] 用戶端 ID: `794985788833-3vjtmctgom3ff9jnmu0pl4q4m0eig01m.apps.googleusercontent.com`
- [ ] 類型: iOS
- [ ] Bundle ID: 與 iOS 專案一致

#### 2. OAuth 同意畫面
- [ ] 使用者類型已設定
- [ ] 應用程式名稱已設定
- [ ] 使用者支援電子郵件已設定
- [ ] 開發人員聯絡資訊已設定

#### 3. 已啟用的 API
- [ ] Google Sign-In API 已啟用
- [ ] Identity Platform API 已啟用（如使用 Supabase）

## 快速檢查連結

### Google Cloud Console
- **專案首頁**: https://console.cloud.google.com/home/dashboard?project=vigor-django-dev
- **OAuth 憑證**: https://console.cloud.google.com/apis/credentials?project=vigor-django-dev
- **OAuth 同意畫面**: https://console.cloud.google.com/apis/credentials/consent?project=vigor-django-dev
- **API 庫**: https://console.cloud.google.com/apis/library?project=vigor-django-dev

## 檢查腳本

執行以下腳本進行自動檢查（需要安裝 gcloud CLI）:
```bash
bash check_project_setting.sh
```

## 比較檢查

請參考 `PROJECT_SETTING_COMPARISON.md` 進行詳細的設定比較和檢查。
