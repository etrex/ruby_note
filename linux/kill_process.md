# 查詢所有 process
```
ps
```
輸出
```
  PID TTY           TIME CMD
21968 ttys000    0:00.16 -bash
```

# 查詢 port 3000 被誰占用
```
lsof -i :3000

```
輸出
```
COMMAND   PID  USER   FD   TYPE             DEVICE SIZE/OFF NODE NAME
ruby    20308 etrex   25u  IPv4 0xd000000000000      0t0  TCP *:hbci (LISTEN)
```

# 刪除某個 process
```
kill 20308
```

# 強制刪除某個 process
```
kill -9 20308
```

# 參考文件
kill process:[https://blog.gtwang.org/linux/linux-kill-killall-xkill/](https://blog.gtwang.org/linux/linux-kill-killall-xkill/)
