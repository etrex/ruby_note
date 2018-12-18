require 'action_dispatch'
require 'byebug'

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