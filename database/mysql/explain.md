# EXPLAIN

如果在 explain 中有看不懂的詞可以到這裡查：https://dev.mysql.com/doc/refman/5.7/en/explain-output.html


一個 explain 範例：

```
EXPLAIN SELECT * FROM orders LEFT JOIN customers USING (customerNumber);
```

輸出

```
+----+-------------+-----------+------------+--------+---------------+---------+---------+-------------------------------------+------+----------+-------+
| id | select_type | table     | partitions | type   | possible_keys | key     | key_len | ref                  | rows | filtered | Extra |
+----+-------------+-----------+------------+--------+---------------+---------+---------+-------------------------------------+------+----------+-------+
|  1 | SIMPLE      | orders    | NULL       | ALL    | NULL          | NULL    | NULL    | NULL                  |  421 |   100.00 | NULL  |
|  1 | SIMPLE      | customers | NULL       | eq_ref | PRIMARY       | PRIMARY | 4       | classicmodels.orders.customerNumber |    1 |   100.00 | NULL  |
+----+-------------+-----------+------------+--------+---------------+---------+---------+-------------------------------------+------+----------+-------+
2 rows in set, 1 warning (0.00 sec)
```

select_type 可以用來看出東西有沒有被 cache

key 跟 possible_keys 有東西代表有用 index

要看 key 欄有沒有使用合理的 index

看 rows 的值有沒有過大

Extra 欄位如果出現 Using filesort 或 Using temporary 時要注意

filesort 的意思是排序後的結果取出後需要再做二次處理

temporary 表示會開一個暫存表格做查詢
