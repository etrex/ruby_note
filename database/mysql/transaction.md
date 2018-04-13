# 交易(Transaction)

ACID

- Atomicity   原子性：只有全部成功或全部失敗，舉例：銀行轉帳
- Consistency 一致性：確保資料滿足所有 Constraint
- Isolation   隔離性：
- Durability  持久性：


## Isolation 的等級

隔離等級越高，效能越差
但在 MySQL，REPEATABLE-READ 的效能比 READ-COMMITTED

- SERIALIZABLE：最高等級，保證多個交易同時跑，結果會跟每筆交易獨立跑的順序相同。
- REPEATABLE-READ：如果查特定一筆資料，保證不被其他交易影響。
- READ-COMMITTED：可能讀到其他交易寫入的資料
- READ－UNCOMMITTED：可能讀到其他交易還沒寫入的資料


## Phantom reads

Transaction 1

SELECT * FROM users WHERE age BETWEEN 20 TO 30;

Transaction 2

INSERT

## Non-repeatable reads

Transaction 1

SELECT * FROM users WHERE id = 1

Transaction 2

UPDATE 1

## Dirty reads

Transaction 1

SELECT * FROM users WHERE id = 1

Transaction 2

UPDATE 1
ROLLBACK

# 其他隔離性

Snapshot Isolation(SI)
  SERIALIZABLE > SI > READ-COMMITTED