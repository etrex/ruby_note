
# 從 bz2 匯入 db

```
bzcat file_name | mysql database_name -u root -p
```

file_name 副檔名應為 .sql.bz2
database 必須為空資料庫


# 進入 mysql 並且建立一個空資料庫
```
mysql -u root -p
CREATE DATABASE database_name;
```
