# 環境變數的顯示

``` sql
SHOW VARIABLES;
```

# 只查看特定的變數

``` sql
SHOW VARIABLES LIKE 'time_zone';
```

# 修改環境變數的值

``` sql
SET time_zone = '+8:00';
```

修改的環境變數只會影響當下的連線

``` bash
$ rails db
mysql> SHOW VARIABLES LIKE 'time_zone';
+---------------+--------+
| Variable_name | Value  |
+---------------+--------+
| time_zone     | SYSTEM |
+---------------+--------+
1 row in set (0.02 sec)

mysql> SET time_zone = '+8:00';
Query OK, 0 rows affected (0.00 sec)

mysql> exit
Bye

$ rails db
mysql> SHOW VARIABLES LIKE 'time_zone';
+---------------+--------+
| Variable_name | Value  |
+---------------+--------+
| time_zone     | SYSTEM |
+---------------+--------+
1 row in set (0.01 sec)
```