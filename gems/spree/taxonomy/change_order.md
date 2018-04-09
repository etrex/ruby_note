# 分類的排序改變時發生了什麼事？

## Taxonomies

在 `http://localhost:3000/admin/taxonomies` 頁面，可以拖曳分類，改變分類的顯示順序。

直接拖曳後可以透過瀏覽器看到發出了一個 POST 給 `http://localhost:3000/admin/taxonomies/update_positions`，並且以 query string 的格式傳遞以下資料：

```
positions[2]: 1
positions[1]: 2
positions[3]: 3
```

會收到 `ok`。

### js

在 spree 原始碼中的 `backend/app/assets/javascripts/spree/backend/admin.js` 第 325 行：

``` js
$('table.sortable').ready(function(){
  var td_count = $(this).find('tbody tr:first-child td').length
  $('table.sortable tbody').sortable(
    {
      handle: '.handle',
      helper: fixHelper,
      placeholder: 'ui-sortable-placeholder',
      update: function(event, ui) {
        var tbody = this;
        $("#progress").show();
        positions = {};
        $.each($('tr', tbody), function(position, obj){
          reg = /spree_(\w+_?)+_(\d+)/;
          parts = reg.exec($(obj).prop('id'));
          if (parts) {
            positions['positions['+parts[2]+']'] = position+1;
          }
        });
        $.ajax({
          type: 'POST',
          dataType: 'script',
          url: $(ui.item).closest("table.sortable").data("sortable-link"),
          data: positions,
          success: function(data){ $("#progress").hide(); }
        });
      },
      start: function (event, ui) {
        // Set correct height for placehoder (from dragged tr)
        ui.placeholder.height(ui.item.height())
        // Fix placeholder content to make it correct width
        ui.placeholder.html("<td colspan='"+(td_count-1)+"'></td><td class='actions'></td>")
      },
      stop: function (event, ui) {
        // Fix odd/even classes after reorder
        $("table.sortable tr:even").removeClass("odd even").addClass("even");
        $("table.sortable tr:odd").removeClass("odd even").addClass("odd");
      }

    });
});
```

可以發現 url 被藏在 data("sortable-link") 裡。

### controller

在 spree 原始碼中的 `backend/app/controllers/spree/admin/taxonomies_controller.rb`

```ruby
module Spree
  module Admin
    class TaxonomiesController < ResourceController
      private

      def location_after_save
        if @taxonomy.created_at == @taxonomy.updated_at
          edit_admin_taxonomy_url(@taxonomy)
        else
          admin_taxonomies_url
        end
      end
    end
  end
end
```

```ruby
class Spree::Admin::ResourceController < Spree::Admin::BaseController
  include Spree::Backend::Callbacks

  helper_method :new_object_url, :edit_object_url, :object_url, :collection_url
  before_action :load_resource, except: :update_positions
  rescue_from ActiveRecord::RecordNotFound, with: :resource_not_found

  respond_to :html

  ...

  def update_positions
    ApplicationRecord.transaction do
      params[:positions].each do |id, index|
        model_class.find(id).set_list_position(index)
      end
    end

    respond_to do |format|
      format.js { render plain: 'Ok' }
    end
  end

  ...

end
```

可以發現到，這裡是直接對 model 做 set_list_position。

set_list_position 是一個在 [acts_as_list](https://github.com/swanandp/acts_as_list) 套件中定義的函數。


## Taxon

在 http://localhost:3000/admin/taxonomies/1/edit 頁面，可以拖曳子分類，改變子分類的顯示順序。

直接拖曳後，瀏覽器發出了一個 POST 給 `http://localhost:3000/api/v1/taxonomies/1/taxons/12`，以 query string 傳遞以下資料：

```
_method: put
taxon[parent_id]: 1
taxon[child_index]: 0
token: 7d14c68de4b43ffe2b6f5f9244bb0a15182707e3c97fc4b5
```

會收到一個 json：

```json
{
  "id":12,
  "name":"QQ",
  "pretty_name":"衣服 -\u003e QQ",
  "permalink":"categories/bags/qq",
  "parent_id":1,
  "taxonomy_id":1,
  "meta_title":null,
  "meta_description":null,
  "taxons":[

  ]
}
```

### js

在 spree 原始碼中的 `backend/app/assets/javascripts/spree/backend/taxonomy.js.coffee` 第 5 行：

```coffee
handle_move = (e, data) ->
  last_rollback = data.rlbk
  position = data.rslt.cp
  node = data.rslt.o
  new_parent = data.rslt.np

  url = Spree.url(base_url).clone()
  url.setPath url.path() + '/' + node.prop("id")
  $.ajax
    type: "POST",
    dataType: "json",
    url: url.toString(),
    data: {
      _method: "put",
      "taxon[parent_id]": new_parent.prop("id"),
      "taxon[child_index]": position,
      token: Spree.api_key
    },
    error: (XMLHttpRequest, textStatus, errorThrown) ->
      handle_ajax_error(last_rollback)

  true
```

### controller

在 spree 原始碼中的 `api/app/controllers/spree/api/v1/taxons_controller.rb` 第 49 行：

```ruby
  def update
    authorize! :update, taxon
    if taxon.update_attributes(taxon_params)
      respond_with(taxon, status: 200, default_template: :show)
    else
      invalid_resource!(taxon)
    end
  end
```

繼續追查之後發現在 Taxon 身上有一個 child_index= 方法。

```ruby
# TODO: let friendly id take care of sanitizing the url
require 'stringex'

module Spree
  class Taxon < Spree::Base
    extend FriendlyId
    friendly_id :permalink, slug_column: :permalink, use: :history
    before_validation :set_permalink, on: :create, if: :name

    acts_as_nested_set dependent: :destroy

    ...

    # awesome_nested_set sorts by :lft and :rgt. This call re-inserts the child
    # node so that its resulting position matches the observable 0-indexed position.
    # ** Note ** no :position column needed - a_n_s doesn't handle the reordering if
    #  you bring your own :order_column.
    #
    #  See #3390 for background.
    def child_index=(idx)
      move_to_child_with_index(parent, idx.to_i) unless new_record?
    end

    ...

  end
end
```
會呼叫 move_to_child_with_index 方法，這個方法被定義在 [awesome_nested_set](https://github.com/collectiveidea/awesome_nested_set) 裡面。

可以看到 Spree::Taxon 有寫 `acts_as_nested_set dependent: :destroy` 這行來使用 [awesome_nested_set](https://github.com/collectiveidea/awesome_nested_set) 套件。

總而言之，我們可以透過：

```ruby
Spree::Taxon.find(taxon_id).child_index = 0
```
去調整 taxon 的順序。可以設定的值介於 0 至 n-1。設定 child_index = 0 時，表示排在最前，設定 child_index = 1 時，表示排在第二位，以此類推。
