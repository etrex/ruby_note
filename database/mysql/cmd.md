# 使用 bash 去操作 MySQL

檢查本機 mysql server 是否正在執行
```bash
brew services list
```

執行本機 mysql server
```bash
brew services start mysql
```

登入 mysql server
```bash
mysql -u root -p
```
其中 root 是使用者帳號

回應如下：

```bash
Enter password:
```

此時要輸入密碼，預設密碼應該是空的。在正確輸入密碼後會看到：

```bash
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 5
Server version: 5.7.21-20-log Percona Server (GPL), Release '20', Revision 'ed217b06ca3'

Copyright (c) 2009-2018 Percona LLC and/or its affiliates
Copyright (c) 2000, 2018, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql>
```
