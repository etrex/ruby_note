# 安裝 Redis
## 在 macOS 上安裝 Redis
使用 homebrew 來安裝 redis

```bash
brew install redis
```

# Redis Server
### 開啟

```bash
redis-server
```

# Redis Client

### 開啟

```bash
redis-cli
```

### 列出所有資料

```
keys *
```

### 寫入一筆資料

set key value
```
set foo 1
=> OK
```

### 讀取一筆資料

get key

```
get foo
=> "1"
```
