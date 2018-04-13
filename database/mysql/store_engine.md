# 儲存引擎

## 重要
- InnoDB
- MyISAM

## 不重要
- MEMORY
- CSV
- ARCHIVE
- BLACKHOLE
- MERGE
- FEDERATED
- EXAMPLE

MEMORY 早期在用，後來就不用，改用 mencache
BLACKHOLE 是用來測試用的，不管下什麼 query 都是空的

# MyISAM
MySQL 5.5 以前的預設引擎

- 當機重啓時要跑手動修復程式，而且會掉資料
- 不支援 Transaction
- 寫入時使用 Exclusive Lock，會導致 TABLE LOCK

# InnoDB
Innobase Oy 覺得 MyISAM 很爛，所以自幹一個

MySQL 5.5 以後的預設引擎

- 當機重啓不會掉資料
- 完整支援 Transaction
- 寫入時使用 MVCC，支援多人同時寫入和讀取
