# 資料庫升級

## 安裝 postgresql

安裝指令

```bash
brew install postgresql
```

brew 安裝好的 postgresql 預設的資料存放位置

```
/usr/local/var/postgres
```

[postgres app](https://postgresapp.com/) 安裝好的 postgresql 預設的資料存放位置

```
/Users/etrex/Library/Application Support/Postgres/var-9.6
```

我當時裝的時候是裝 9.6。

## postgresql server 的啟動與停止

如果是在 brew 安裝

啟動
```
brew services start postgresql
```

或者
```
pg_ctl -D /usr/local/var/postgres start
```
其中 `/usr/local/var/postgres` 是資料的路徑。


重啓
```
brew services restart postgresql
```

停止
```
brew services stop postgresql
```

查看是否運作中
```
brew services list
```

如果是裝 postgres app，直接在應用程式資料夾中執行 postgres(大象圖示)

## postgresql client 的啟動

```
psql
```

必須先啟動 postgre server

## 資料的備份

先將原本的資料改名字，如果原本是 brew 安裝的話：

```
cd /usr/local/var
mv postgres/ postgres-96-backup
```

如果原本是用 [postgres app](https://postgresapp.com/) 安裝的話：

```
cd /usr/local/var
cp -r /Users/etrex/Library/Application\ Support/Postgres/var-9.6 .
mv var-9.6/ postgres-96-backup
```

## 資料的重置

使用 initdb 來建立一個空的資料，先確認 initdb 的版本是不是新版。

```
initdb --version
```

指定資料夾

```
cd /usr/local/var
rm -rf postgres
initdb /usr/local/var/postgres/
```

在 initdb 時可以指定資料庫的 owner 和語系設定等。

-U 指定 owner，我使用 `postgres`
-E 指定編碼，我使用 `UTF-8`
--locale 指定語系，我使用 `en_US`

```
initdb /usr/local/var/postgres -U postgres -E UTF-8 --locale en_US
```

會指定這些參數而不使用預設值，是因為我需要從 postgres app 升級到 brew 上的 postgres，而這些是 postgres app 的預設值。

## 建立預設的資料庫

如果在連線至資料庫 `psql` 時遇到以下錯誤訊息：

```
psql: FATAL:  database 你的名字 does not exist
```

可以使用以下指令建立預設資料庫：

```
createdb
```

## 資料庫升級

使用 pg_upgrade 來做資料庫升級

-b 指定舊版的 bin 路徑，我們使用 `/Applications/Postgres.app/Contents/Versions/latest/bin/`
-B 指定新版的 bin 路徑，我們使用 `/usr/local/Cellar/postgresql/10.3/bin/`
-d 指定舊版的 data 路徑，我們使用 `/usr/local/var/postgres-96-backup/`
-D 指定新版的 data 路徑，我們使用 `/usr/local/var/postgres`

```
pg_upgrade -b /Applications/Postgres.app/Contents/Versions/latest/bin/ -B /usr/local/Cellar/postgresql/10.3/bin/ -d /usr/local/var/postgres-96-backup/ -D /usr/local/var/postgres
```

升級完成後會產生兩個檔案：
- analyze_new_cluster.sh
- delete_old_cluster.sh

我們執行他

```
analyze_new_cluster.sh
delete_old_cluster.sh
```

之後就可以把這兩個檔案刪除
```
rm analyze_new_cluster.sh
rm delete_old_cluster.sh
```
