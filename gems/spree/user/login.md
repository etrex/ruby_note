# 為什麼 spree 需要兩個登入頁？

從 `rails routes | grep login` 可以看到 login 有兩種。

Prefix                   | Verb | URI                    | Controller#Action
------------------------ | ---- | ---------------------- | -----------------------------
login                    | GET  | /login(.:format)       | spree/user_sessions#new
create_new_session       | POST | /login(.:format)       | spree/user_sessions#create
admin_login              | GET  | /admin/login(.:format) | spree/admin/user_sessions#new
admin_create_new_session | POST | /admin/login(.:format) | spree/admin/user_sessions#create

從 Controller 開始追。

Controller 有兩個，分別是 [Spree::UserSessionsController](https://github.com/spree/spree_auth_devise/blob/master/lib/controllers/frontend/spree/user_sessions_controller.rb) 和 [Spree::Admin::UserSessionsController](https://github.com/spree/spree_auth_devise/blob/master/lib/controllers/backend/spree/admin/user_sessions_controller.rb)，他們被定義在 spree_auth_devise 這個套件裡。

