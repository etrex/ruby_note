# 資料型態
## 數字
### 整數
- TINYINT：1byte
- SMALLINT：2byte
- MEDIUMINT：3byte（少見）
- INT：4byte
- BIGINT：8byte

TINYINT UNSIGNED 只有非負整數

INT(10)的(10)當年是設計用來做排版的，現在已經沒用途。

### 浮點數

- FLOAT
- DOUBLE
- DECIMAL：精確的值

## 字串CHAR

- CHAR(4) 四個字
- VARCHAR(4) 用 x 個 byte 去存總共需要幾個byte去儲存字，然後接著存字。

根據所使用的
UTF-8 每個字需要 3 個 byte

VARCHAR(100) 所需要的最大 byte 數 = 3 * 100 + 2 = 302 byte

總共 100 個 UTF-8 的字元，需要額外的 2 個 byte 去儲存字串所需要的byte數 300

### 如何選擇用 CHAR 還是 VARCHAR？
VARCHAR 彈性好

VARCHAR 的 INDEX 永遠使用最大 BYTE 數空間來表示一個值

### 建議不要對 CHAR、VARCHAR 做 INDEX
這會讓 INDEX 的大小變得很大

### 可以只對字串的前 N 個字做 INDEX
MySQL：PARTIAL INDEX
postgresql：FUNCTIONAL INDEX
```
https://www.postgresql.org/docs/9.5/static/indexes-expressional.html
```

## 字串TEXT

TINYTEXT
TEXT
MEDIUMTEXT
LONGTEXT

不能做 Index

## 日期與時間

- DATE
- DATETIME
- TIME
- TIMESTAMP
- YEAR

- INT
- INT UNSIGNED

建議儲存 UTC 時間
某些時候會使用 INT，INT 的好處：跨平台

## BOOL
實際上是 TINYINT

另外還有這兩種：
ENUM (2byte)
SET