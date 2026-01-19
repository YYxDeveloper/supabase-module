# Supabase 用戶查詢與同步系統

完整的 Supabase Authentication Users 到 Chats Users 自動同步解決方案。

## 📊 系統概述

本系統解決了 `auth.users` (認證系統) 和 `chats.users` (聊天系統) 之間的資料同步問題。

### 核心功能

✅ **自動同步** - 新用戶註冊時自動建立聊天記錄  
✅ **現有用戶同步** - 一鍵同步所有現有用戶  
✅ **更新同步** - 用戶資料更新時自動同步  
✅ **RLS 政策** - 正確的權限控制設定  
✅ **查詢工具** - 便捷的命令列查詢工具  

### 當前狀態

```
auth.users:  4 筆用戶 ✓
chats.users: 4 筆用戶 ✓
同步狀態:    正常 ✓
```

## 🚀 快速開始

### 1. 查詢用戶

```bash
# 查詢認證系統用戶
dart run scripts/query_auth_direct.dart

# 查詢聊天系統用戶
./scripts/load_env.sh
```

### 2. 驗證同步

```bash
./scripts/verify_sync.sh
```

### 3. 設定同步（首次使用）

```bash
# 1. 複製 SQL 到剪貼簿
pbcopy < scripts/setup_auth_sync.sql

# 2. 前往 SQL Editor 執行
open https://supabase.com/dashboard/project/dknjuzjbudprjrgdzaeo/sql

# 3. 驗證同步
./scripts/verify_sync.sh
```

## 📚 文件

### 完整指南

- **[完整實作流程](docs/SUPABASE_USER_QUERY_AND_SYNC_FLOW.md)** - 詳細的技術文件，包含所有代碼和命令
  - 問題診斷流程
  - 完整代碼實作
  - 測試與驗證
  - 疑難排解

### 快速參考

- **[快速參考](docs/QUICK_REFERENCE.md)** - 常用命令和 SQL 速查表
- **[同步設定指南](docs/AUTH_SYNC_GUIDE.md)** - 同步機制詳細說明
- **[RLS 設定指南](docs/RLS_SETUP_GUIDE.md)** - Row Level Security 配置

## 🛠️ 工具與腳本

### 查詢工具

| 腳本 | 功能 | 用法 |
|------|------|------|
| `query_auth_direct.dart` | 查詢 auth.users | `dart run scripts/query_auth_direct.dart` |
| `check_users_count.dart` | 查詢 chats.users | `./scripts/load_env.sh` |
| `verify_sync.sh` | 驗證同步狀態 | `./scripts/verify_sync.sh` |

### 設定 SQL

| SQL 檔案 | 功能 | 執行位置 |
|---------|------|----------|
| `setup_users_rls.sql` | 設定 RLS 政策 | SQL Editor |
| `setup_auth_sync.sql` | 設定自動同步 | SQL Editor |
| `check_table_structure.sql` | 檢查表格結構 | SQL Editor |

### 輔助腳本

| 腳本 | 功能 |
|------|------|
| `load_env.sh` | 載入環境變數並查詢 |
| `check_auth.sh` | 快速查詢 auth users |

## 🏗️ 架構說明

### 資料流

```
註冊/更新
    ↓
auth.users ──[Trigger]──→ chats.users
    │                         │
    │                         │
    ▼                         ▼
Admin API              REST API
(service_role)         (anon key)
```

### 觸發器機制

```sql
-- 當 auth.users 有變更時自動執行
CREATE TRIGGER on_auth_user_created
  AFTER INSERT OR UPDATE ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION sync_auth_user_to_chats();
```

### 資料對應

```
auth.users                  →  chats.users
─────────────────────────────────────────────
id                          →  id
email (前綴)                →  first_name
raw_user_meta_data         →  first_name/last_name
created_at                 →  created_at
```

## 📋 系統需求

### 必要條件

- ✅ Dart SDK (已安裝)
- ✅ Supabase CLI (v2.67.1+)
- ✅ Bash Shell
- ✅ `.env` 檔案配置

### 環境變數

```env
SUPABASE_URL=https://dknjuzjbudprjrgdzaeo.supabase.co
SUPABASE_ANON_KEY=your_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
```

## 🔍 疑難排解

### 常見問題

#### 查詢返回 0

**原因**: RLS 政策阻擋  
**解決**: 執行 `scripts/setup_users_rls.sql`

#### 同步失敗

**原因**: 觸發器未設定  
**解決**: 執行 `scripts/setup_auth_sync.sql`

#### API Key 無效

**原因**: 環境變數未設定或過期  
**解決**: 
```bash
supabase projects api-keys --project-ref dknjuzjbudprjrgdzaeo
# 更新 .env 檔案
```

詳細疑難排解請參閱：[完整實作流程 - 疑難排解章節](docs/SUPABASE_USER_QUERY_AND_SYNC_FLOW.md#維護與疑難排解)

## 📊 監控

### 定期檢查

```bash
# 每日檢查同步狀態
./scripts/verify_sync.sh

# 檢查觸發器狀態（在 SQL Editor）
SELECT * FROM pg_trigger WHERE tgname = 'on_auth_user_created';

# 檢查最近同步記錄
SELECT * FROM chats.users ORDER BY updated_at DESC LIMIT 5;
```

## 🔐 安全考量

- ✅ 使用 `SECURITY DEFINER` 確保觸發器有適當權限
- ✅ RLS 政策限制 API 存取
- ✅ Service Role Key 僅用於管理操作
- ✅ 不同步敏感資料（密碼、token）

## 📈 效能優化

- 觸發器使用 `AFTER` 而非 `BEFORE`，避免阻塞
- 使用 `ON CONFLICT DO UPDATE` 處理重複
- 索引優化查詢效能
- 批量同步支援大量用戶

## 🎯 下一步

### 建議改進

- [ ] 增加錯誤通知機制
- [ ] 建立同步失敗重試邏輯
- [ ] 添加監控 Dashboard
- [ ] 實作資料驗證機制
- [ ] 建立自動化測試

### 相關功能

- [ ] 用戶頭像同步
- [ ] 用戶狀態同步
- [ ] 雙向同步支援
- [ ] 歷史記錄追蹤

## 🤝 貢獻

本系統由 AI Assistant 協助建立，記錄於 2026-01-19。

### 專案結構

```
subabase_park/
├── scripts/                    # 查詢與同步腳本
│   ├── query_auth_direct.dart
│   ├── check_users_count.dart
│   ├── verify_sync.sh
│   ├── load_env.sh
│   ├── setup_users_rls.sql
│   └── setup_auth_sync.sql
├── docs/                       # 完整文件
│   ├── SUPABASE_USER_QUERY_AND_SYNC_FLOW.md
│   ├── QUICK_REFERENCE.md
│   ├── AUTH_SYNC_GUIDE.md
│   └── RLS_SETUP_GUIDE.md
├── .env                        # 環境變數（不提交）
└── README_SUPABASE_SYNC.md     # 本文件
```

## 📞 支援

### 文件資源

- [Supabase 官方文件](https://supabase.com/docs)
- [PostgreSQL Triggers](https://www.postgresql.org/docs/current/triggers.html)
- [Row Level Security](https://supabase.com/docs/guides/auth/row-level-security)

### 專案連結

- [Supabase Dashboard](https://supabase.com/dashboard/project/dknjuzjbudprjrgdzaeo)
- [SQL Editor](https://supabase.com/dashboard/project/dknjuzjbudprjrgdzaeo/sql)
- [Authentication](https://supabase.com/dashboard/project/dknjuzjbudprjrgdzaeo/auth/users)

---

## 📝 版本歷史

### v1.0.0 (2026-01-19)

- ✅ 初始查詢系統
- ✅ RLS 政策設定
- ✅ 自動同步機制
- ✅ 完整文件
- ✅ 驗證工具

### 當前用戶

```
1. downlolow@gmail.com
2. always996@icloud.com
3. yyxdev@gmail.com
4. amazonforyoung@gmail.com
```

---

**最後更新**: 2026-01-19  
**狀態**: ✅ 運作正常  
**下次檢查**: 建議每週執行 `./scripts/verify_sync.sh`
