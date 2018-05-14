# heroku 的備份在本機上還原

```
createdatabase db_name
pg_restore -D db_name backup_file_path
```

其中，db_name 是資料庫名稱，backup_file_path 是備份檔路徑

可能會遇到錯誤訊息是本機沒有和 heroku 在建立 table 或 index 時，相同名稱的 user。

可以使用 createuser 去加相同名稱的 user 或者是重新建立一個不包含 user 資訊的新的備份檔。