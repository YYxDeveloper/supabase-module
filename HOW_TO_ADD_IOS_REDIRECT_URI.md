# 如何添加 iOS URL Scheme 到 Google Cloud OAuth 重新導向 URI

## 📋 需要添加的 URI

```
com.googleusercontent.apps.794985788833-4o2ctjvoenha3pq85qn6kkld57frtovk:/
com.googleusercontent.apps.794985788833-4o2ctjvoenha3pq85qn6kkld57frtovk://
```

---

## 🔧 詳細步驟

### 步驟 1：前往 Google Cloud Console

1. **打開瀏覽器**，前往以下連結：
   ```
   https://console.cloud.google.com/apis/credentials?project=vigor-django-dev
   ```
   或使用專案編號：
   ```
   https://console.cloud.google.com/apis/credentials?project=794985788833
   ```

2. **登入**你的 Google 帳號（如果尚未登入）

---

### 步驟 2：找到 Web OAuth 2.0 Client ID

1. 在「OAuth 2.0 用戶端 ID」列表中，找到以下 Client ID：
   ```
   794985788833-4o2ctjvoenha3pq85qn6kkld57frtovk.apps.googleusercontent.com
   ```
   - 類型應該顯示為「**網頁應用程式**」
   - 如果列表很長，可以使用瀏覽器的搜尋功能（Ctrl+F 或 Cmd+F）搜尋 `4o2ctjvoenha3pq85qn6kkld57frtovk`

---

### 步驟 3：編輯 Client ID

1. **點擊**該 Client ID 的名稱或右側的「**編輯**」按鈕（鉛筆圖示）

---

### 步驟 4：添加重新導向 URI

1. 在編輯頁面中，找到「**已授權的重新導向 URI**」區塊
   - 這個區塊通常在頁面中間或下方
   - 可能已經有一些 URI（如 `http://localhost` 等）

2. **點擊「+ 新增 URI」**按鈕（通常在 URI 列表下方）

3. **在第一個輸入框中輸入**：
   ```
   com.googleusercontent.apps.794985788833-4o2ctjvoenha3pq85qn6kkld57frtovk:/
   ```

4. **再次點擊「+ 新增 URI」**按鈕

5. **在第二個輸入框中輸入**：
   ```
   com.googleusercontent.apps.794985788833-4o2ctjvoenha3pq85qn6kkld57frtovk://
   ```

---

### 步驟 5：儲存變更

1. **向下滾動**到頁面底部
2. **點擊「儲存」**按鈕（通常在右下角）
3. 等待確認訊息出現（通常會顯示「已儲存」或「已更新」）

---

## ✅ 確認設定

完成後，你應該在「已授權的重新導向 URI」列表中看到：

```
✓ com.googleusercontent.apps.794985788833-4o2ctjvoenha3pq85qn6kkld57frtovk:/
✓ com.googleusercontent.apps.794985788833-4o2ctjvoenha3pq85qn6kkld57frtovk://
```

---

## ⚠️ 重要提醒

1. **設定生效時間**：變更後需要 **5-10 分鐘** 才會生效
2. **兩個 URI 都需要添加**：`:/` 和 `://` 兩個版本都要添加
3. **不要刪除現有的 URI**：只添加新的，不要刪除現有的 Web URI
4. **大小寫敏感**：確保 URI 完全正確，包括大小寫

---

## 🖼️ 視覺化指引

```
Google Cloud Console
└── API 和服務
    └── 憑證
        └── OAuth 2.0 用戶端 ID
            └── [794985788833-4o2ctjvoenha3pq85qn6kkld57frtovk] ← 點擊編輯
                └── 已授權的重新導向 URI
                    ├── [現有 URI 1]
                    ├── [現有 URI 2]
                    ├── [+] 新增 URI ← 點擊這裡
                    │   └── 輸入: com.googleusercontent.apps.794985788833-4o2ctjvoenha3pq85qn6kkld57frtovk:/
                    └── [+] 新增 URI ← 再次點擊
                        └── 輸入: com.googleusercontent.apps.794985788833-4o2ctjvoenha3pq85qn6kkld57frtovk://
```

---

## 🐛 常見問題

### ⚠️ **錯誤：重新導向無效：必須使用 HTTP 或 HTTPS 通訊協定**

**問題說明：**
當嘗試添加 `com.googleusercontent.apps.794985788833-4o2ctjvoenha3pq85qn6kkld57frtovk:/` 時，Google Cloud Console 顯示錯誤：「重新導向無效：必須使用 HTTP 或 HTTPS 通訊協定」。

**原因：**
- **Web OAuth Client ID 不支援 custom scheme URI**（如 `com.googleusercontent.apps.xxx:/`）
- Web Client ID 只接受 HTTP/HTTPS 協議的 URI
- Custom scheme 只能添加到 **iOS OAuth Client ID** 中

**解決方案：**

由於我們需要使用 Web Client ID 來確保 ID Token 的 audience 與 Supabase 配置一致，有兩個選擇：

#### **方案 1：使用 iOS Client ID（推薦）**

1. **切換回使用 iOS Client ID**
   - 修改 `ios/Runner/Info.plist` 中的 `GIDClientID` 為 iOS Client ID
   - 修改 `lib/main.dart` 讓 iOS 使用 iOS Client ID

2. **在 Supabase 中配置 iOS Client ID**
   - 前往 Supabase Dashboard
   - 在 Authentication > Providers > Google 設定中
   - 添加 iOS Client ID 作為允許的 OAuth Client ID

#### **方案 2：使用 iOS Client ID 並處理 Audience 驗證**

如果 Supabase 不支援多個 Client ID，可能需要：
- 使用 iOS Client ID 進行登入
- 在後端處理 ID Token 驗證時，同時接受 Web 和 iOS Client ID

---

### Q: 找不到「+ 新增 URI」按鈕？
A: 確保你已經點擊了「編輯」按鈕，並且在「已授權的重新導向 URI」區塊中。如果還是找不到，嘗試重新整理頁面。

### Q: 輸入 URI 後無法儲存？
A: 
- 確認 URI 格式完全正確（包括冒號和斜線）
- 確認沒有多餘的空格
- 嘗試複製貼上提供的 URI
- **注意**：Web Client ID 不接受 custom scheme，必須使用 iOS Client ID

### Q: 儲存後多久生效？
A: 通常需要 **5-10 分鐘**。如果立即測試失敗，請稍等片刻後再試。

### Q: 需要刪除現有的 URI 嗎？
A: **不需要**。只添加新的 iOS URL scheme，保留現有的 Web URI。

---

## 🔗 快速連結

**直接前往編輯頁面**（需要先登入）：
```
https://console.cloud.google.com/apis/credentials?project=vigor-django-dev
```

---

## 📝 檢查清單

完成設定後，確認：

- [ ] 已找到 Web Client ID (`794985788833-4o2ctjvoenha3pq85qn6kkld57frtovk`)
- [ ] 已點擊「編輯」按鈕
- [ ] 已添加 `com.googleusercontent.apps.794985788833-4o2ctjvoenha3pq85qn6kkld57frtovk:/`
- [ ] 已添加 `com.googleusercontent.apps.794985788833-4o2ctjvoenha3pq85qn6kkld57frtovk://`
- [ ] 已點擊「儲存」
- [ ] 已確認兩個 URI 都出現在列表中
- [ ] 已等待 5-10 分鐘讓設定生效
