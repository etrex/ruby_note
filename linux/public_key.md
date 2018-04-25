# 生成金鑰

在 bash 下輸入：

```
ssh-keygen
```

# 取出生成的金鑰

```
cat ~/.ssh/id_rsa.pub | pbcopy
```

- cat：將檔案變成字串
- |：pipe 運算子
- pbcopy：複製到剪貼簿
