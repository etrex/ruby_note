本文嘗試觀察 Rails 透過什麼方式來解析輸入的網址，找到對應的 controller action 以及 params，然後自幹一個。

### 參考資料
- [Rack 應用程式](https://railsbook.tw/extra/rack.html)
- [尝试理解 ActionDispatch::Routing::RouteSet](https://ruby-china.org/topics/30916)

由於篇幅的關係，請先花個 1～2 分鐘大概讀一下參考資料再繼續往下閱讀。

想要自幹一個 Rails Router 就要從了解 Rails Router 開始。

# 了解 Rails Router

在參考資料中，我們得到了一個寶貴的資訊：

> ActionDispatch::Routing::RouteSet 是一個 Rack App。

也就是說 RouteSet 有一個 call 方法，並且他會傳回符合 Rack 規範的內容。
[https://github.com/rails/rails/blob/master/actionpack/lib/action_dispatch/routing/route_set.rb#L832](https://github.com/rails/rails/blob/master/actionpack/lib/action_dispatch/routing/route_set.rb#L832)：

```ruby
def call(env)
  req = make_request(env)
  req.path_info = Journey::Router::Utils.normalize_path(req.path_info)
  @router.serve(req)
end
```

這就是 Rack App 的進入點。他在這裡是製作 request，然後丟給 `@router.serve` 方法去處理。

這個 @router 的 class 是 `ActionDispatch::Journey::Router`。

https://github.com/rails/rails/blob/master/actionpack/lib/action_dispatch/journey/router.rb#L31

```ruby
def serve(req)
  find_routes(req).each do |match, parameters, route|
    # 略
    status, headers, body = route.app.serve(req)
    # 略
    return [status, headers, body]
  end

  [404, { "X-Cascade" => "pass" }, ["Not Found"]]
end
```

大意：用 `find_routes` 找出對應的 route 之後，執行 `route.app.serve`。

這個 route 的 class 是 `ActionDispatch::Journey::Route`。

這個 route.app 的 class 是 `ActionDispatch::Routing::RouteSet::Dispatcher`。

我們繼續看他到底 serve 了什麼。
[https://github.com/rails/rails/blob/master/actionpack/lib/action_dispatch/routing/route_set.rb#L29](https://github.com/rails/rails/blob/master/actionpack/lib/action_dispatch/routing/route_set.rb#L29)：

```ruby
def serve(req)
  params     = req.path_parameters
  controller = controller req
  res        = controller.make_response! req
  dispatch(controller, params[:action], req, res)
rescue ActionController::RoutingError
  if @raise_on_name_error
    raise
  else
    [404, { "X-Cascade" => "pass" }, []]
  end
end

def controller(req)
  req.controller_class
rescue NameError => e
  raise ActionController::RoutingError, e.message, e.backtrace
end

def dispatch(controller, action, req, res)
  controller.dispatch(action, req, res)
end
```

在這裡可以看出，他直接從 `req.controller_class` 找到對應的 controller 並且做處理，然後就回傳結果了。

可以看出 controller class 需要支援兩個方法：
- make_response!(request)
- dispatch(action, request, response)

且 dispatch 的輸入值 response 正好就是 make_response! 的輸出。

# 自幹一個 Rack App

所以我們可以仿照參考資料的做法，自己做一個 Rack App 來試用看看：

首先弄一個空資料夾，然後在裡面建立一個 `config.ru` 檔案，內容如下：

```ruby
require 'action_dispatch'

class EtrexController
  def self.make_response!(request)
  end
  def self.dispatch(action, req, res)
    [200, {"Content-Type" => "text/html"}, ['QQ']]
  end
end

app = ActionDispatch::Routing::RouteSet.new

app.draw do
  get 'etrex', to: 'etrex#index'
end

run app
```

因為 make_response! 的輸出也只有我們自己用，所以就乾脆不在 make_response! 做事了。

你可以在 bash 下用 `rackup` 指令來執行這個 Rack App 。

接著在瀏覽器輸入對應的網址 [http://localhost:9292/etrex](http://localhost:9292/etrex) 就可以看到結果「QQ」。

# 繼續了解 Rails Router

我們已經知道整個 RouterSet 大概做了些什麼事，接下來我們就專注在本文重點：Router 是如何將 request 轉換為 controller action 和 params。

```ruby
def find_routes(req)
  routes = filter_routes(req.path_info).concat custom_routes.find_all { |r|
    r.path.match(req.path_info)
  }

  routes =
    if req.head?
      match_head_routes(routes, req)
    else
      match_routes(routes, req)
    end

  routes.sort_by!(&:precedence)

  routes.map! { |r|
    match_data = r.path.match(req.path_info)
    path_parameters = {}
    match_data.names.zip(match_data.captures) { |name, val|
      path_parameters[name.to_sym] = Utils.unescape_uri(val) if val
    }
    [match_data, path_parameters, r]
  }
end
```

這個程式碼很長，我們一段一段來解讀。

```ruby
  routes = filter_routes(req.path_info).concat custom_routes.find_all { |r|
    r.path.match(req.path_info)
  }
```

因為我先偷看了 filter_routes 的實作，所以我知道這段是用一個不單純的演算法，根據網址來排除 routes，而後面的 `.concat custom_routes ...` 可以先忽略，感覺不是重點。

```ruby
routes =
  if req.head?
    match_head_routes(routes, req)
  else
    match_routes(routes, req)
  end
```

這段則是根據 http method 來排除 routes。

```ruby
  routes.sort_by!(&:precedence)

  routes.map! { |r|
    match_data = r.path.match(req.path_info)
    path_parameters = {}
    match_data.names.zip(match_data.captures) { |name, val|
      path_parameters[name.to_sym] = Utils.unescape_uri(val) if val
    }
    [match_data, path_parameters, r]
  }
```

因為有可能多重 match，這裡就依照優先序排序，然後把所有結果都整理好傳回。同時，他也在這裡做了網址參數的解析。

其中的 r.path 的 class 是 ActionDispatch::Journey::Path::Pattern。

r.path.match 方法如下：

```ruby
def match(other)
  return unless match = to_regexp.match(other)
  MatchData.new(names, offsets, match)
end
```

我們從上而下的解讀，未必要完全理解，透過實際觀察其輸入輸出，就能知道他大概的意圖。

他這裡想要解析的參數是在 router 規則中的 `etrex/:id` 之類的變數。

舉例來說，我們會期待用一個 `get 'etrex/:id'` 來捕捉所有 `etrex/1`、`etrex/2`、`etrex/3`... 的網址。

而我們希望 router 能從中解析出參數 {id: 1}，而這段 match 就是在做這件事。

# 觀察小結

Rails 的 router 中有許多的 route，每一個 route 負責保存一組規則，明確指向特定的 controller 以及 action。在建立 route 時，就已經進行了一些預處理來做加速。

Rails 在 router 上定義 find_routes 方法，比對 uri 以及 http method 來找出需要的 route，並且即時生成正規表示式來做參數解析。

# 開始自幹 Router

我們的目標是要讓 `get 'etrex/:id', to: 'etrex#show'` 能運作，儘量用最少最好讀的 code 來完成，效能什麼的在這裡不是重點。

```ruby
require 'action_dispatch'
require 'cgi'

class Router
  def initialize
    @routes = []
  end

  # 設定規則
  def draw(&block)
    self.instance_exec(&block)
  end

  def get(pattern, options)
    @routes << Route.new('get', pattern, options)
  end

  # 程式進入點
  def call(env)
    route = find_route(env)
    return route.serve(env) if route.present?
    [404, {"Content-Type" => "text/html"}, ['404 not found']]
  end

  private

  def find_route(env)
    method = env['REQUEST_METHOD'].downcase
    path = env['PATH_INFO'].downcase

    @routes.find do |route|
      route.match?(method, path)
    end
  end
end

class Route
  def initialize(method, pattern, options)
    @method = method.downcase
    @pattern = pattern.downcase
    controller_name, @action = options[:to].split('#')
    @controller = controller_class(controller_name)
  end

  def match?(method, path)
    match_method(method) && match_path(path)
  end

  def serve(env)
    query_string_params = Rack::Utils.parse_nested_query env['QUERY_STRING']
    params = in_path_params.merge(query_string_params)
    @controller.dispatch(@action, params, env)
  end

  private

  def in_path_params
    @in_path_params
  end

  def controller_class(controller_name)
    Object.const_get("#{ controller_name.capitalize }Controller")
  end

  def match_method(method)
    @method == method
  end

  def match_path(path)
    path = path[1..-1] if path[0] == '/'
    path_words = path.split('/')
    pattern_words = @pattern.split('/')

    return false unless path_words.count == pattern_words.count

    # 在 match 的同時紀錄在網址中的 params
    @in_path_params = {}
    pattern_words.zip(path_words).each do | pattern_word, path_word |
      if pattern_word[0] == ':'
        @in_path_params[pattern_word[1..-1]] = path_word
      else
        return false unless pattern_word == path_word
      end
    end
    true
  end
end

class BaseController
  attr_accessor :params
  def initialize(params)
    @params = params
  end

  def self.dispatch(action, params, env)
    body = self.new(params).send(action)
    [200, {"Content-Type" => "text/html"}, [body]]
  end
end

# 以上都是框架的部分
# 以下看起來像是正常的 rails code

class EtrexController < BaseController
  def index
    "etrex/index, params: #{params}"
  end

  def show
    "etrex/show, params: #{params}"
  end
end

app = Router.new

app.draw do
  get 'etrex', to: 'etrex#index'
  get 'etrex/:id', to: 'etrex#show'
end

run app
```

我做了最基礎的 Router 架構，可以把規則變成 Route 物件保存在 @routes 中，由 Route 提供 match 方法，並在 match 網址的同時擷取出網址中的參數。

同時也做了基礎的 controller 結構，確認能夠正常取得來自網址以及 query string 的參數。到這裡總算是入門囉！！

> 「What I cannot create, I do not understand.」 Richard Philip Feynman