# 檔案索引 - Supabase 用戶查詢與同步系統

## 📁 專案檔案清單

本文件列出所有為 Supabase 用戶查詢與同步功能建立的檔案。

---

## 📄 文件檔案

### 主要文件

| 檔案 | 路徑 | 說明 |
|------|------|------|
| **完整實作流程** | `docs/SUPABASE_USER_QUERY_AND_SYNC_FLOW.md` | 🌟 最詳細的技術文件，包含診斷流程、完整代碼、測試與疑難排解 |
| **快速參考** | `docs/QUICK_REFERENCE.md` | ⚡ 常用命令、SQL 速查表、快速疑難排解 |
| **專案 README** | `README_SUPABASE_SYNC.md` | 📋 專案總覽、快速開始、架構說明 |
| **檔案索引** | `docs/FILES_INDEX.md` | 📑 本文件 - 所有檔案的清單和說明 |

### 指南文件

| 檔案 | 路徑 | 說明 |
|------|------|------|
| **同步設定指南** | `docs/AUTH_SYNC_GUIDE.md` | 詳細的同步機制設定步驟 |
| **RLS 設定指南** | `docs/RLS_SETUP_GUIDE.md` | Row Level Security 政策設定指南 |

---

## 💻 查詢腳本 (Dart)

### 主要查詢工具

| 檔案 | 路徑 | 功能 | 執行方式 |
|------|------|------|----------|
| **Auth Users 查詢** | `scripts/query_auth_direct.dart` | 查詢 `auth.users` 表格（認證系統用戶） | `dart run scripts/query_auth_direct.dart` |
| **Chats Users 查詢** | `scripts/check_users_count.dart` | 查詢 `chats.users` 表格（聊天系統用戶） | `dart run scripts/check_users_count.dart` |

### 輔助工具

| 檔案 | 路徑 | 功能 |
|------|------|------|
| **RLS 狀態檢查** | `scripts/check_rls_status.dart` | 診斷工具 - 檢查 RLS 政策和表格狀態 |
| **Auth Users 計數** | `scripts/check_auth_users_count.dart` | 提示如何查詢 auth.users |
| **RPC 設定** | `scripts/setup_rls_policy.dart` | RPC 函數設定提示 |

---

## 🐚 Shell 腳本

### 執行腳本

| 檔案 | 路徑 | 功能 | 執行方式 |
|------|------|------|----------|
| **環境變數載入** | `scripts/load_env.sh` | 載入 `.env` 並執行查詢 | `./scripts/load_env.sh` |
| **驗證同步** | `scripts/verify_sync.sh` | 驗證 auth 和 chats users 同步狀態 | `./scripts/verify_sync.sh` |
| **Auth 查詢快捷** | `scripts/check_auth.sh` | 快速查詢 auth users | `./scripts/check_auth.sh` |
| **直接執行 SQL** | `scripts/execute_sql_direct.sh` | SQL 執行輔助腳本 | `./scripts/execute_sql_direct.sh` |

---

## 🗄️ SQL 檔案

### 設定 SQL

| 檔案 | 路徑 | 功能 | 執行位置 |
|------|------|------|----------|
| **🌟 自動同步設定** | `scripts/setup_auth_sync.sql` | 建立觸發器和同步現有用戶 | SQL Editor |
| **RLS 政策設定** | `scripts/setup_users_rls.sql` | 設定 `chats.users` 讀取權限 | SQL Editor |
| **簡化 RLS 設定** | `scripts/setup_rls_simple.sql` | RLS 政策簡化版本 | SQL Editor |

### 查詢與診斷 SQL

| 檔案 | 路徑 | 功能 |
|------|------|------|
| **Auth Users 查詢** | `scripts/check_auth_users.sql` | 查詢 auth.users 的 SQL |
| **RLS 政策檢查** | `scripts/check_rls_policies.sql` | 檢查 RLS 狀態和政策 |
| **表格結構檢查** | `scripts/check_table_structure.sql` | 檢查 chats.users 結構 |
| **RPC 函數建立** | `scripts/create_auth_users_rpc.sql` | 建立查詢 auth.users 的 RPC 函數 |

---

## 🔧 Migration 檔案

| 檔案 | 路徑 | 說明 |
|------|------|------|
| **RLS Migration** | `supabase/migrations/20260119154150_setup_chats_users_rls.sql` | Supabase migration 格式的 RLS 設定 |

---

## 📊 檔案統計

### 按類型分類

```
文件 (Markdown):    6 個
Dart 腳本:         5 個
Shell 腳本:        4 個
SQL 檔案:          8 個
Migration:         1 個
─────────────────────
總計:             24 個
```

### 按功能分類

```
📚 文件與指南:      6 個
🔍 查詢工具:        5 個
🔄 同步機制:        3 個
🔐 安全設定 (RLS):  4 個
🐚 執行輔助:        4 個
🗄️ Migration:       1 個
🔧 診斷工具:        1 個
```

---

## 🎯 使用建議

### 新手入門順序

1. 📖 閱讀 `README_SUPABASE_SYNC.md` - 了解系統概述
2. 📋 參考 `docs/QUICK_REFERENCE.md` - 學習常用命令
3. 🚀 執行 `./scripts/load_env.sh` - 測試查詢功能
4. 📚 深入閱讀 `docs/SUPABASE_USER_QUERY_AND_SYNC_FLOW.md` - 理解完整實作

### 問題排查順序

1. 🔍 檢查 `docs/QUICK_REFERENCE.md` 的疑難排解章節
2. 📖 查閱 `docs/SUPABASE_USER_QUERY_AND_SYNC_FLOW.md` 的維護章節
3. 🛠️ 使用診斷腳本 `scripts/check_rls_status.dart`
4. 📋 參考各個指南文件的具體說明

### 設定與維護

1. **首次設定**:
   - `scripts/setup_users_rls.sql`
   - `scripts/setup_auth_sync.sql`
   - `./scripts/verify_sync.sh`

2. **日常維護**:
   - `./scripts/verify_sync.sh` (每週執行)
   - `./scripts/load_env.sh` (查詢 chats users)
   - `dart run scripts/query_auth_direct.dart` (查詢 auth users)

---

## 🔗 檔案關聯圖

```
README_SUPABASE_SYNC.md (入口)
    │
    ├─→ docs/QUICK_REFERENCE.md (快速參考)
    │
    ├─→ docs/SUPABASE_USER_QUERY_AND_SYNC_FLOW.md (完整流程)
    │   ├─→ scripts/check_users_count.dart
    │   ├─→ scripts/query_auth_direct.dart
    │   ├─→ scripts/setup_users_rls.sql
    │   └─→ scripts/setup_auth_sync.sql
    │
    ├─→ docs/AUTH_SYNC_GUIDE.md (同步指南)
    │   └─→ scripts/setup_auth_sync.sql
    │
    └─→ docs/RLS_SETUP_GUIDE.md (RLS 指南)
        └─→ scripts/setup_users_rls.sql

執行腳本關聯:
    load_env.sh → check_users_count.dart
    check_auth.sh → query_auth_direct.dart
    verify_sync.sh → query_auth_direct.dart + check_users_count.dart
```

---

## 📝 建立日期與版本

| 項目 | 值 |
|------|-----|
| **建立日期** | 2026-01-19 |
| **版本** | 1.0.0 |
| **專案** | Supabase User Query and Sync System |
| **狀態** | ✅ 完成並運作中 |

---

## 🔄 檔案更新記錄

### 2026-01-19 - Initial Release

- ✅ 建立所有核心查詢腳本
- ✅ 建立完整文件系統
- ✅ 設定 RLS 政策
- ✅ 實作自動同步機制
- ✅ 建立驗證工具

---

## 📌 重要提醒

### 不要刪除的檔案

❗ **核心查詢工具**:
- `scripts/query_auth_direct.dart`
- `scripts/check_users_count.dart`
- `scripts/load_env.sh`

❗ **同步機制**:
- `scripts/setup_auth_sync.sql`
- `scripts/verify_sync.sh`

❗ **主要文件**:
- `docs/SUPABASE_USER_QUERY_AND_SYNC_FLOW.md`
- `README_SUPABASE_SYNC.md`

### 可以安全刪除的檔案

如果空間有限，以下檔案可以刪除（可從主要檔案重建）:
- `scripts/check_rls_status.dart`
- `scripts/setup_rls_policy.dart`
- `scripts/execute_sql_direct.sh`
- `scripts/check_auth_users_count.dart`

---

## 🎓 學習資源

### 相關技術

- **Dart**: HTTP 請求處理、JSON 解析
- **PostgreSQL**: Triggers、Functions、RLS
- **Bash**: Shell 腳本、環境變數
- **Supabase**: REST API、Auth Admin API

### 推薦閱讀順序

1. `README_SUPABASE_SYNC.md` - 快速了解
2. `docs/QUICK_REFERENCE.md` - 實用命令
3. `docs/SUPABASE_USER_QUERY_AND_SYNC_FLOW.md` - 深入學習
4. 實際執行腳本進行實驗

---

**本索引文件最後更新**: 2026-01-19  
**維護者**: AI Assistant  
**文件完整性**: ✅ 所有檔案已記錄
