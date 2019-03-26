參考文件：https://developers.google.com/web/updates/2017/04/headless-chrome

# 在 MacOS 使用 bash 開啟一個 chrome 瀏覽器

Chrome 安裝完成之後會在以下資料夾中找到一個名為 Google Chrome 的可執行檔
```
/Applications/Google Chrome.app/Contents/MacOS/
```

在 bash 中，空白符號需要加上跳脫符號`\`，所以使用 bash 執行 Google Chrome 要這樣寫：

```
/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome
```

可以使用 alias 指令作出 chrome 的短指令：

```
alias chrome="/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome"
```

# 使用 headless chrome

```bash
chrome --headless
```

# 印出 DOM(document.body.innerHTML)
```bash
chrome --headless --disable-gpu --dump-dom https://www.chromestatus.com/
```

# 生成 PDF
```bash
chrome --headless --disable-gpu --print-to-pdf https://www.chromestatus.com/
```

# 網頁截圖
```bash
chrome --headless --disable-gpu --screenshot https://www.chromestatus.com/
```

# 調整截圖大小
```bash
chrome --headless --disable-gpu --screenshot --window-size=1280,1696 https://www.chromestatus.com/
```

# Nexus 5x
```bash
chrome --headless --disable-gpu --screenshot --window-size=412,732 https://www.chromestatus.com/
```

# 互動模式(read-eval-print loop)
```bash
$ chrome --headless --disable-gpu --repl --crash-dumps-dir=./tmp https://www.chromestatus.com/
[0608/112805.245285:INFO:headless_shell.cc(278)] Type a Javascript expression to evaluate or "quit" to exit.
>>> location.href
{"result":{"type":"string","value":"https://www.chromestatus.com/features"}}
>>> quit
$
```