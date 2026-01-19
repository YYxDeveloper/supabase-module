# Supabase Sync System 資料夾說明

## 📁 資料夾位置

```
/Users/qw/YYx/subabase_park/supabase_sync_system/
```

## 🎯 用途

這個資料夾包含所有在 **2026-01-19** 對話中建立的 Supabase 用戶查詢與同步系統相關檔案。

## 📊 內容摘要

```
supabase_sync_system/
├── README.md                     ← 📖 檔案功能完整摘要（必讀）
├── README_SUPABASE_SYNC.md       ← 📋 專案總覽
├── scripts/                      ← 💻 9 個腳本（Dart + Shell）
├── sql/                          ← 🗄️ 7 個 SQL 設定檔
├── docs/                         ← 📚 6 個詳細文件
└── migrations/                   ← 📦 1 個 migration 檔案

總計：24 個檔案
```

## 🚀 快速開始

### 1. 閱讀摘要

```bash
cd supabase_sync_system
open README.md
```

### 2. 查看完整文件

```bash
open docs/SUPABASE_USER_QUERY_AND_SYNC_FLOW.md
```

### 3. 執行查詢

```bash
# 查詢 auth.users
dart run scripts/query_auth_direct.dart

# 查詢 chats.users
./scripts/load_env.sh

# 驗證同步
./scripts/verify_sync.sh
```

## 📚 重要文件

| 文件 | 說明 |
|------|------|
| `README.md` | **必讀** - 所有檔案功能的完整摘要 |
| `README_SUPABASE_SYNC.md` | 專案總覽和架構說明 |
| `docs/HOW_TO_EXECUTE_SQL_IN_DASHBOARD.md` | 如何在 Dashboard 執行 SQL |
| `docs/QUICK_REFERENCE.md` | 常用命令速查表 |
| `docs/SUPABASE_USER_QUERY_AND_SYNC_FLOW.md` | 完整技術文件（800+ 行）|

## 🎯 主要功能

### 1. 查詢工具
- 查詢 `auth.users`（認證系統用戶）
- 查詢 `chats.users`（聊天系統用戶）
- 驗證同步狀態

### 2. 同步機制
- 自動同步 `auth.users` → `chats.users`
- 觸發器設定
- 現有用戶批量同步

### 3. 安全設定
- RLS (Row Level Security) 政策
- 權限控制

### 4. 完整文件
- 技術文件
- 使用指南
- 疑難排解

## 💡 使用場景

**適合以下情況參考**：
- ✅ 需要同步 Supabase auth.users 到自訂表格
- ✅ 學習 PostgreSQL Triggers
- ✅ 了解 RLS 設定
- ✅ Dart HTTP API 查詢範例
- ✅ Shell 腳本自動化

## 📦 檔案類型

```
Markdown:  7 個  (文件)
Dart:      5 個  (查詢腳本)
Shell:     4 個  (執行腳本)
SQL:       7 個  (設定檔)
Migration: 1 個  (資料庫遷移)
```

## 🔗 相關連結

- [Supabase Dashboard](https://supabase.com/dashboard/project/dknjuzjbudprjrgdzaeo)
- [SQL Editor](https://supabase.com/dashboard/project/dknjuzjbudprjrgdzaeo/sql)

## ✅ 專案狀態

- **狀態**: ✅ 完成
- **測試**: ✅ 已測試
- **文件**: ✅ 完整
- **可用性**: ✅ 可直接使用

## 📝 注意事項

1. 需要先設定 `.env` 檔案（包含 Supabase 連接資訊）
2. Dart SDK 需要安裝
3. 首次使用需要在 Dashboard 執行同步 SQL

## 🎓 學習價值

這個專案是一個完整的實作案例，包含：
- 問題診斷過程
- 解決方案設計
- 完整代碼實作
- 詳細文件
- 疑難排解

---

**建立日期**: 2026-01-19  
**版本**: 1.0.0  
**維護者**: AI Assistant

---

**進入資料夾開始使用**：

```bash
cd supabase_sync_system
cat README.md
```
