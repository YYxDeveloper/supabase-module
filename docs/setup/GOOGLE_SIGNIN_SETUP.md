# Google Sign-In 設定指南

## Android SHA-1 憑證指紋設定

### 當前設定的 SHA-1 憑證指紋
```
3F:60:9F:C0:A1:11:5D:0C:2B:8A:3C:C3:B9:7E:5F:79:26:07:C8:93
```

### 設定步驟

1. **登入 Google Cloud Console**
   - 前往：https://console.cloud.google.com/
   - 選擇你的專案：
     - 專案 ID: `vigor-django-dev`
     - 專案編號: `794985788833`

2. **設定 OAuth 同意畫面**
   - 導航至「API 和服務」>「OAuth 同意畫面」
   - 完成必要的設定

3. **設定 OAuth 2.0 用戶端 ID**
   - 導航至「API 和服務」>「憑證」
   - 找到或創建 Android 類型的 OAuth 2.0 用戶端 ID
   - 在「SHA-1 憑證指紋」欄位中新增：
     ```
     3F:60:9F:C0:A1:11:5D:0C:2B:8A:3C:C3:B9:7E:5F:79:26:07:C8:93
     ```
   - 套件名稱（Package name）應為：
     ```
     com.example.subabase_park
     ```

4. **驗證設定**
   - 確認 Android OAuth 用戶端 ID 已正確設定
   - 確認 SHA-1 憑證指紋已新增
   - 確認套件名稱正確

### 當前配置摘要

#### Web Client ID
```
794985788833-4o2ctjvoenha3pq85qn6kkld57frtovk.apps.googleusercontent.com
```

#### Android Server Client ID
```
794985788833-4o2ctjvoenha3pq85qn6kkld57frtovk.apps.googleusercontent.com
```

#### iOS Client ID
```
794985788833-3vjtmctgom3ff9jnmu0pl4q4m0eig01m.apps.googleusercontent.com
```

#### Android SHA-1 憑證指紋 (Debug)
```
3F:60:9F:C0:A1:11:5D:0C:2B:8A:3C:C3:B9:7E:5F:79:26:07:C8:93
```

#### Android 套件名稱
```
com.example.subabase_park
```

### 常見問題排查

1. **錯誤：Account reauth failed**
   - 確認 SHA-1 憑證指紋已在 Google Cloud Console 中正確設定
   - 確認套件名稱與 `android/app/build.gradle.kts` 中的 `applicationId` 一致
   - 等待幾分鐘讓 Google Cloud Console 的變更生效

2. **錯誤：clientConfigurationError**
   - 確認 `serverClientId` 已正確設定在 `lib/main.dart` 中
   - 確認使用的是 Web Client ID（OAuth 2.0 Client ID）

3. **驗證 SHA-1 憑證指紋**
   ```bash
   # Debug keystore
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   
   # Release keystore (如果有的話)
   keytool -list -v -keystore <path-to-keystore> -alias <alias-name>
   ```

### 注意事項

- SHA-1 憑證指紋必須在 Google Cloud Console 中設定，無法在 Flutter 程式碼中設定
- 設定完成後，可能需要等待幾分鐘讓變更生效
- 如果使用不同的 keystore（例如 release keystore），需要分別設定對應的 SHA-1 憑證指紋
- 確保 Google Sign-In API 已在 Google Cloud Console 中啟用
