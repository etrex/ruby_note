#在不同的頁面載入不同的 JS
在 [RailsGuides:The Asset Pipeline](http://guides.rubyonrails.org/asset_pipeline.html) 中，描述了 JS 和 CSS 載入的詳細流程。


在 layout 中寫入以下的 code，就可以只載入特定的 controller 對應的 JS，但必須確保在 application.js 中沒有寫 `require_tree`。

```
<%= javascript_include_tag params[:controller] %> or <%= stylesheet_link_tag
params[:controller] %>
```
