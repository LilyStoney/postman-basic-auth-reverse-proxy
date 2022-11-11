require 'rack'
require 'rack/reverse_proxy'

use Rack::ReverseProxy do
    reverse_proxy /(\/\S+)/, "https://documenter.getpostman.com$1"
end

map '/' do
    use Rack::Auth::Basic do |username, password|
        username == ENV['USERNAME'] && password == ENV['PASSWORD']
    end

    use Rack::ReverseProxy do
        reverse_proxy /(\/$)/, "https://documenter.getpostman.com/view/#{ENV['DOCUMENTATION_SLUG']}$1"
    end
end

app = proc do |env|
    [ 301, { "Location" => "https://documenter.getpostman.com/view/#{ENV['DOCUMENTATION_SLUG']}" }, [] ]
end

run app
