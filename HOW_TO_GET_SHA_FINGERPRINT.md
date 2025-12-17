# 如何取得 Android 專案的 SHA 指紋

## 📱 SHA 指紋說明

SHA 指紋（SHA-1/SHA-256）是用於識別 Android 應用程式簽名憑證的唯一標識符。Google Sign-In 需要 SHA-1 憑證指紋來驗證應用程式。

## 🔍 方法 1: 使用 keytool（Debug Keystore）

### Debug Keystore（開發用）

Debug keystore 是 Android SDK 自動生成的，用於開發和測試。

```bash
# 取得 SHA-1 指紋
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# 只顯示 SHA-1
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android | grep SHA1

# 只顯示 SHA-256
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android | grep SHA256
```

**預設密碼**:
- Store password: `android`
- Key password: `android`
- Alias: `androiddebugkey`

### 輸出範例

```
Certificate fingerprints:
     SHA1: 3F:60:9F:C0:A1:11:5D:0C:2B:8A:3C:C3:B9:7E:5F:79:26:07:C8:93
     SHA256: 8E:2E:5F:C9:2D:87:B9:12:23:8F:B0:6E:BB:32:D8:70:63:14:6B:16:15:96:F9:E7:84:23:0D:C8:8E:E5:78:F0
```

## 🔍 方法 2: 使用 Gradle（推薦）

### 在專案根目錄建立腳本

建立檔案：`android/get_sha.sh`

```bash
#!/bin/bash

echo "=== Android SHA 指紋 ==="
echo ""

# Debug Keystore
echo "Debug Keystore SHA-1:"
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android 2>/dev/null | grep SHA1 | sed 's/.*SHA1: //'

echo ""
echo "Debug Keystore SHA-256:"
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android 2>/dev/null | grep SHA256 | sed 's/.*SHA256: //'

echo ""
echo "=== Release Keystore ==="
echo "如果您有 Release keystore，請執行："
echo "keytool -list -v -keystore <path-to-keystore> -alias <alias-name>"
```

### 執行腳本

```bash
chmod +x android/get_sha.sh
./android/get_sha.sh
```

## 🔍 方法 3: 使用 Gradle Task（自動化）

### 在 `android/app/build.gradle.kts` 中添加任務

```kotlin
android {
    // ... 現有設定 ...

    // 添加任務來顯示 SHA 指紋
    tasks.register("printSha1") {
        doLast {
            val keystoreFile = file("${System.getProperty("user.home")}/.android/debug.keystore")
            if (keystoreFile.exists()) {
                exec {
                    commandLine(
                        "keytool",
                        "-list",
                        "-v",
                        "-keystore", keystoreFile.absolutePath,
                        "-alias", "androiddebugkey",
                        "-storepass", "android",
                        "-keypass", "android"
                    )
                }
            } else {
                println("Debug keystore not found at ${keystoreFile.absolutePath}")
            }
        }
    }
}
```

### 執行 Gradle 任務

```bash
cd android
./gradlew printSha1
```

## 🔍 方法 4: 使用 Android Studio

### 步驟

1. **開啟 Android Studio**
2. **開啟 Gradle 面板**
   - 右側邊欄 > Gradle
3. **執行簽名報告**
   - 展開專案 > Tasks > android > signingReport
   - 雙擊執行
4. **查看輸出**
   - 在底部的 Run 面板中查看 SHA-1 和 SHA-256

### 或使用終端機

```bash
cd android
./gradlew signingReport
```

## 🔍 方法 5: 從已安裝的應用程式取得

### 使用 adb（如果應用程式已安裝）

```bash
# 列出所有已安裝的應用程式
adb shell pm list packages | grep your.package.name

# 取得應用程式的簽名資訊
adb shell dumpsys package your.package.name | grep -A 1 "signatures"
```

## 📋 不同 Keystore 的 SHA 指紋

### Debug Keystore（開發用）

**位置**: `~/.android/debug.keystore`

```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

### Release Keystore（發布用）

**位置**: 您自己創建的 keystore（通常在專案目錄或安全位置）

```bash
# 替換為您的實際路徑和別名
keytool -list -v -keystore /path/to/your/release.keystore -alias your-alias-name

# 系統會提示輸入密碼
```

### 範例：Release Keystore

```bash
keytool -list -v -keystore android/app/release.keystore -alias release-key-alias
```

## 🔧 快速檢查腳本

建立檔案：`check_sha.sh`

```bash
#!/bin/bash

echo "=========================================="
echo "Android SHA 指紋檢查工具"
echo "=========================================="
echo ""

# 檢查 Debug Keystore
DEBUG_KEYSTORE="$HOME/.android/debug.keystore"

if [ -f "$DEBUG_KEYSTORE" ]; then
    echo "✅ Debug Keystore 找到: $DEBUG_KEYSTORE"
    echo ""
    echo "SHA-1:"
    keytool -list -v -keystore "$DEBUG_KEYSTORE" -alias androiddebugkey -storepass android -keypass android 2>/dev/null | grep SHA1 | sed 's/.*SHA1: //'
    
    echo ""
    echo "SHA-256:"
    keytool -list -v -keystore "$DEBUG_KEYSTORE" -alias androiddebugkey -storepass android -keypass android 2>/dev/null | grep SHA256 | sed 's/.*SHA256: //'
else
    echo "❌ Debug Keystore 未找到: $DEBUG_KEYSTORE"
fi

echo ""
echo "=========================================="
echo "Release Keystore"
echo "=========================================="
echo "如果您有 Release keystore，請手動執行："
echo "keytool -list -v -keystore <path-to-keystore> -alias <alias-name>"
```

執行：
```bash
chmod +x check_sha.sh
./check_sha.sh
```

## 📝 當前專案的 SHA 指紋

### Debug Keystore SHA-1
```
3F:60:9F:C0:A1:11:5D:0C:2B:8A:3C:C3:B9:7E:5F:79:26:07:C8:93
```

### 驗證命令

```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android | grep SHA1
```

## ⚠️ 重要提醒

### 1. Debug vs Release Keystore

- **Debug Keystore**: 用於開發和測試
  - 位置：`~/.android/debug.keystore`
  - 密碼：`android`
  - 別名：`androiddebugkey`

- **Release Keystore**: 用於發布到 Google Play
  - 位置：您自己創建
  - 密碼：您設定的密碼
  - 別名：您設定的別名

### 2. 多個 SHA 指紋

Google Cloud Console 允許在同一個 Android OAuth 用戶端中設定多個 SHA-1 指紋：
- Debug SHA-1（開發用）
- Release SHA-1（發布用）
- CI/CD SHA-1（如果使用）

### 3. SHA-1 vs SHA-256

- **SHA-1**: Google Sign-In 主要使用 SHA-1
- **SHA-256**: 某些服務可能需要 SHA-256
- 建議同時設定兩者（如果 Google Cloud Console 支援）

## 🔗 相關文件

- `FIX_SHA1_ISSUE.md` - SHA-1 問題修復指南
- `PROJECT_INFO.md` - 專案資訊摘要

## 📊 快速參考

### 最常用的命令

```bash
# 取得 Debug SHA-1
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android | grep SHA1

# 取得 Debug SHA-256
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android | grep SHA256

# 取得 Release SHA-1（需要替換路徑和別名）
keytool -list -v -keystore /path/to/release.keystore -alias your-alias | grep SHA1
```
