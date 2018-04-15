# SQL指令

只要是在 `mysql>` 下輸入的內容就算 SQL 指令

## 列出 Databases

```sql
SHOW DATABASES;
```

輸出

```sql
+--------------------+
| Database           |
+--------------------+
| information_schema |
| classicmodels      |
| mysql              |
| performance_schema |
| sys                |
+--------------------+
5 rows in set (0.00 sec)
```

## 使用 Database

```sql
USE classicmodels;
```

`classicmodels` 是 Table 名稱。

輸出

```sql
Database changed
```

## 列出 Tables

```sql
SHOW TABLES;
```

輸出

```sql
+-------------------------+
| Tables_in_classicmodels |
+-------------------------+
| customers               |
| employees               |
| offices                 |
| orderdetails            |
| orders                  |
| payments                |
| productlines            |
| products                |
| table1                  |
+-------------------------+
9 rows in set (0.00 sec)
```

## 列出 Table 的 Columns

```sql
DESC products;
```

其中，products 是表格名稱

輸出：

```sql
+--------------------+---------------+------+-----+---------+-------+
| Field              | Type          | Null | Key | Default | Extra |
+--------------------+---------------+------+-----+---------+-------+
| productCode        | varchar(15)   | NO   | PRI | NULL    |       |
| productName        | varchar(70)   | NO   |     | NULL    |       |
| productLine        | varchar(50)   | NO   | MUL | NULL    |       |
| productScale       | varchar(10)   | NO   |     | NULL    |       |
| productVendor      | varchar(50)   | NO   |     | NULL    |       |
| productDescription | text          | NO   |     | NULL    |       |
| quantityInStock    | smallint(6)   | NO   |     | NULL    |       |
| buyPrice           | decimal(10,2) | NO   |     | NULL    |       |
| MSRP               | decimal(10,2) | NO   |     | NULL    |       |
+--------------------+---------------+------+-----+---------+-------+
9 rows in set (0.00 sec)
```

## 列出 Table 中的 Indexs

```sql
SHOW INDEX FROM products;
```

輸出

```sql
+----------+------------+-------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
| Table    | Non_unique | Key_name    | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment |
+----------+------------+-------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
| products |          0 | PRIMARY     |            1 | productCode | A         |         146 |     NULL | NULL   |      | BTREE      |         |               |
| products |          1 | productLine |            1 | productLine | A         |           7 |     NULL | NULL   |      | BTREE      |         |               |
+----------+------------+-------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
2 rows in set (0.00 sec)
```

## 開表格

```sql
CREATE TABLE table1 (col1 INT(1), col2 INT(2), col3 INT(3));
```

輸出

```sql
Query OK, 0 rows affected (0.07 sec)
```

## 寫入資料

```sql
INSERT INTO table1 (col1, col2, col3) VALUES(10000, 10000, 10000);
```

輸出

```sql
Query OK, 1 row affected (0.00 sec)
```

## 查詢

```sql
SELECT * FROM table1;
```

輸出

```sql
+-------+-------+-------+
| col1  | col2  | col3  |
+-------+-------+-------+
| 10000 | 10000 | 10000 |
+-------+-------+-------+
1 row in set (0.00 sec)
```

## 加欄位


## 刪欄位


## LEFT JOIN

```sql
SELECT table1.col1, table2.col2 FROM table1 LEFT JOIN table2 USING (id);
SELECT table1.col1, table2.col2 FROM table1 LEFT JOIN table2 ON ...;
```

從左邊找右邊

## RIGHT JOIN

```sql
SELECT table1.col1, table2.col2 FROM table1 RIGHT JOIN table2 USING (id);
SELECT table1.col1, table2.col2 FROM table1 RIGHT JOIN table2 ON ...;
```

從右邊找左邊

## INNER JOIN（& CROSS JOIN）

CROSS JOIN 是完全展開笛卡兒積（Cartesian product）

```sql
SELECT table1.col1, table2.col2 FROM table1 CROSS JOIN table2;
```

INNER JOIN 是 CROSS JOIN 的特例

```sql
SELECT table1.col1, table2.col2 FROM table1 INNER JOIN table2 USING (id);
```

## NATURAL JOIN
自動找兩個 table 中相同名稱的欄位做 join

```sql
SELECT table1.col1, table2.col2 FROM table1 NATURAL JOIN table2;
SELECT table1.col1, table2.col2 FROM table1 LEFT JOIN table2 USING (id);
```

可是沒人在用

## EXPLAIN

使用時把分號改成 \G 可以把表格呈現改成條列式呈現

```
EXPLAIN SELECT * FROM products \G
```

輸出

```
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: products
   partitions: NULL
         type: ALL
possible_keys: NULL
          key: NULL
      key_len: NULL
          ref: NULL
         rows: 81
     filtered: 100.00
        Extra: NULL
1 row in set, 1 warning (0.00 sec)
```

