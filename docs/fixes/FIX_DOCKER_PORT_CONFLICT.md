# Docker 端口衝突問題修復指南

## 問題描述

啟動 Supabase Docker 容器時出現端口衝突錯誤：

### 錯誤 1：資料庫端口衝突
```
failed to start docker container: Error response from daemon: failed to set up container networking: 
driver failed programming external connectivity on endpoint supabase_db_subabase_park: 
Bind for 0.0.0.0:54322 failed: port is already allocated
```

### 錯誤 2：Analytics 端口衝突
```
failed to start docker container: Error response from daemon: failed to set up container networking: 
driver failed programming external connectivity on endpoint supabase_analytics_subabase_park: 
Bind for 0.0.0.0:54327 failed: port is already allocated
```

## 問題成因分析

多個 Supabase 預設端口已被另一個 Supabase 專案（`supabase_test`）佔用：

- **端口 54322**：被 `supabase_db_supabase_test`（資料庫）佔用
- **端口 54327**：被 `supabase_analytics_supabase_test`（Analytics/Logflare）佔用
- **其他可能衝突的端口**：54321 (Kong), 54323 (Studio), 54324 (Inbucket)

當嘗試啟動 `subabase_park` 專案的 Supabase 容器時，Docker 無法綁定相同的端口，導致啟動失敗。

## 已執行的修復步驟

✅ **已停止佔用端口的容器**
```bash
# 停止資料庫容器
docker stop supabase_db_supabase_test

# 停止 Analytics 容器
docker stop supabase_analytics_supabase_test
```

✅ **已驗證端口釋放**
- 端口 54322 現在已可用
- 端口 54327 現在已可用

## 後續操作

### 1. 啟動當前專案的 Supabase

現在可以重新啟動 `subabase_park` 專案的 Supabase：

```bash
cd /Users/qw/YYx/flutters/subabase_park
supabase start
```

### 2. 如果兩個專案都需要同時運行

如果 `supabase_test` 和 `subabase_park` 兩個專案都需要同時運行，需要修改其中一個專案的端口配置：

#### 步驟：

1. **初始化 Supabase（如果尚未初始化）**
   ```bash
   supabase init
   ```

2. **修改端口配置**
   編輯 `supabase/config.toml` 文件，修改相關端口配置：
   ```toml
   [db]
   port = 54330  # 改為其他未使用的端口
   
   [studio]
   port = 54331
   
   [analytics]
   port = 54332
   
   [inbucket]
   port = 54333
   
   [kong]
   port = 54334
   ```
   
   **注意**：Supabase 使用多個端口，建議將整個端口範圍（54321-54327）改為其他範圍（例如 54330-54337），避免部分端口衝突。

3. **重新啟動**
   ```bash
   supabase stop
   supabase start
   ```

### 3. 檢查 Supabase 狀態

```bash
supabase status
```

## 預防措施

### 方案 A：使用不同的端口配置

為每個 Supabase 專案配置不同的端口範圍，避免衝突。

### 方案 B：使用專案名稱區分

Supabase CLI 會根據專案目錄名稱自動生成容器名稱，確保不同專案使用不同的容器名稱。

### 方案 C：停止不需要的專案

當不需要使用某個 Supabase 專案時，及時停止：
```bash
cd <專案路徑>
supabase stop
```

## 相關指令

### 查看所有 Supabase 容器
```bash
docker ps -a | grep supabase
```

### 查看端口佔用情況
```bash
# 檢查單個端口
lsof -i :54322
lsof -i :54327

# 檢查所有 Supabase 常用端口
for port in 54321 54322 54323 54324 54325 54326 54327; do
    echo "檢查端口 $port:"
    lsof -i :$port || echo "  端口 $port 可用"
done
```

### 停止所有 Supabase 容器
```bash
# 停止所有 Supabase 容器
docker stop $(docker ps -q --filter "name=supabase")

# 或只停止 supabase_test 專案的容器（推薦）
docker stop $(docker ps -q --filter "name=supabase_test")
```

### 清理停止的容器（謹慎使用）
```bash
docker container prune
```

## 注意事項

⚠️ **重要提醒**：
- 停止 `supabase_test` 專案的容器後，該專案的 Supabase 服務將無法使用
- 如果需要同時運行兩個專案，必須修改端口配置
- 修改端口後，記得更新應用程式中的連接配置（如果有的話）

## 修復腳本

已建立多個自動化腳本協助診斷和修復端口衝突問題：

### 1. 完整診斷和修復腳本
`fix_port_conflict.sh` - 檢測所有端口衝突並提供多種解決方案：

```bash
./fix_port_conflict.sh
```

### 2. 快速停止 supabase_test 專案
`stop_supabase_test.sh` - 一次性停止所有 supabase_test 專案的容器（最快速）：

```bash
./stop_supabase_test.sh
```

**已執行結果**：
- ✅ 成功停止 9 個 supabase_test 容器
- ✅ 所有 Supabase 常用端口（54321-54327）已釋放

