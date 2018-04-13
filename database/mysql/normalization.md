# 正規化

減少重複資料

- 避免更新多個地方

導致效能提升

- 快取記憶體使用率提升

## 1NF

- 一個欄位不要放多個值

使用 array 型態資料違反 1NF
使用 string 用分隔符號違反 1NF

- 每個表格都要有 Primary Key
自動遞增：INT UNSIGNED PRIMARY KEY AUTO_INCREMENT
防止掃描：UUID、INT64跳號

Primary Key 的型態會影響 index 的儲存大小和查詢效能
Compound Primary Key：可使用 unique + not null index 做限制，改用自動遞增，避免 Primary Key 過大

MySQL 不保證每次+1，可能+超過1，在分散式架構上不可假設 id 代表寫入順序

## 2NF
同一個變數不要到處存，改用 join 查詢

## 3NF
不要儲存可以從其他欄位計算出來的值

在 MySQL 5.7+, VIRTUAL column 可以建立一個欄位，即時計算

在計算很耗時時會考慮違反 3NF，快取結果。但要注意資料的一致性（快取過期）