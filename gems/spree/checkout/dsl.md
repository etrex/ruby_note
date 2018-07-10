# 修改結帳流程

舉例來說，若我們想要移除 address 和 delivery 兩步驟，那麼我們可以對 Spree::Order 加 decorator 進行以下修改

```ruby
Spree::Order.class_eval do
  remove_checkout_step :address
  remove_checkout_step :delivery
end
```

少掉了兩個步驟之後，你可能需要兩個 callback，一個是在進入結帳頁時（因為 payment 變成第一個步驟了，所以在進入結帳頁就會發生)，一個是在離開結帳頁時，準確的說，是發生在 `order.next` 時。

以下是新增兩個 callback 的程式碼，其中 `setup_payment` 是進入結帳頁時會執行。

```ruby
Spree::Order.class_eval do
  remove_checkout_step :address
  remove_checkout_step :delivery

  state_machine.before_transition to: :payment, do: :setup_payment
  state_machine.before_transition from: :payment, do: :from_payment

  def setup_payment
  end

  def from_payment
  end
end
```

關於 `@order.next`，Spree 使用了 [state machines](https://github.com/state-machines/state_machines) 來做狀態管理。

Spree 定義了一個行為叫做 next，用來做訂單狀態之間的切換。當 order 出問題時，我們可能希望要維持原狀態並且做 rollback。

state machines 會根據 callback 的傳回值來判斷是否成功，若成功則傳回 true，如果我們希望讓他不要成功的話，就要傳回 false。

參考 Spree 原始碼 Spree::CheckoutController 中的 update 方法，會發現如果 `order.next` 失敗的話會進入錯誤處理流程。

```ruby
module Spree
  class CheckoutController < Spree::StoreController

    ...

    def update
      if @order.update_from_params(params, permitted_checkout_attributes, request.headers.env)
        @order.temporary_address = !params[:save_user_address]
        unless @order.next
          flash[:error] = @order.errors.full_messages.join("\n")
          redirect_to(checkout_state_path(@order.state)) && return
        end

        if @order.completed?
          @current_order = nil
          flash.notice = Spree.t(:order_processed_successfully)
          flash['order_completed'] = true
          redirect_to completion_route
        else
          redirect_to checkout_state_path(@order.state)
        end
      else
        render :edit
      end
    end

    ...

  end
end
```

為了使 order 發生錯誤時能夠順利進入錯誤處理流程，我們應該要這樣寫：

```ruby
Spree::Order.class_eval do
  remove_checkout_step :address
  remove_checkout_step :delivery

  state_machine.before_transition to: :payment, do: :setup_payment
  state_machine.before_transition from: :payment, do: :from_payment

  def setup_payment
  end

  def from_payment

    ...

    self.errors.empty?
  end
end
```

在 from_payment 的最後一行加上 `self.errors.empty?` 可以確保當 order 出錯的時候會進入錯誤處理流程。


# to_delivery 做的事

- 刪除所有的 shipments 之後
  - 對所有 line_item 建立對應的 inventory_units
    - 根據 stock_locations 來建立新的 shipments
      - Coordinator
      - InventoryUnitBuilder
      - Packer
      -   Package
      -     ContentItem
      - Prioritizer
      -   Adjuster
      - Estimator

