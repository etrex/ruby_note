# 硬碟滿了怎麼辦？

在 GCP 上的 Compute Engine 硬碟滿了，可以按照以下說明文件操作：

https://cloud.google.com/compute/docs/troubleshooting/troubleshooting-disk-full-resize

# 在 Linux 上有哪些檔案可以刪除？

可以用以下指令查看是哪一個資料夾在雷

```
du -sh * | sort -hr | head
```

References: https://gist.github.com/thebouv/8657674

# /usr/src 很大怎麼辦？

在這個資料夾裡面放了一堆 linux 更新的檔案，但是過期的也不會自動被刪掉。

可以使用以下指令刪除過期的檔案：

```
apt autoremove
```

References: https://help.ubuntu.com/lts/serverguide/automatic-updates.html

另外，這兩個指令可以清除一些其他的東西：

```
apt clean
apt autoclean
```

# /var/log/journal 很大怎麼辦？

查詢 journal 是幹嘛用的

```
man journalctl
```

限制 journal 不會大於 100M

```
journalctl --vacuum-size=100M
```

限制 journal 只保存最近 10 天的內容

```
journalctl --vacuum-time=10d
```

References: https://askubuntu.com/questions/1238214/big-var-log-journal