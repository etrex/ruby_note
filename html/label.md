# 單選/多選按鈕很醜怎麼辦？

使用 label 來作為控制項的點擊感應區，並且隱藏原本的控制項。

當我們點擊 label 時，視為點擊對應的控制項。

舉例來說：

```
<input type="radio" id="控制項的 id">
<label for="這裡放控制項的 id">
  這裡放 radio 的外觀內容
</label>
```

在 label 的 for 指定對應的控制項 id，就完成點擊感應區的連結。