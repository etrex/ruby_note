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