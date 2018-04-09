# 覆寫 Spree 的 JS

直接在 `app/asserts/javascripts/spree` 資料夾下建立一個同名檔案，寫入內容即可。

如果在 `app/asserts/javascripts/spree` 找到同名的檔案，就不會載入 spree 原本的檔案。

在 `app/asserts/javascripts/spree/backend/` 下建立一個檔案：`taxonomy.js` 或 `taxonomy.js.coffee`。寫入以下程式碼：

```
console.log("QQ");
```

# 證明我們寫的檔案被載入

開啟頁面 `http://localhost:3000/admin/taxonomies` 後開啟 console 會發現 "QQ" 顯示在 console 下。

# 證明套件內的檔案沒有被載入

在 console 輸入

```
setup_taxonomy_tree
> VM4005:1 Uncaught ReferenceError: setup_taxonomy_tree is not defined
```