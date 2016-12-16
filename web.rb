require 'rubygems'
require 'sinatra'
require 'json'
require_relative 'guet.rb'

module Sinatra
  class Base
    set :server, %w[thin mongrel webrick]
    set :bind, '0.0.0.0'
    set :port, 8000
    set :views, File.dirname(__FILE__) + '/views'
    set :environment, :production
    set :logging, true

    configure do
      enable :logging
      # file = File.new("#{settings.root}/log/#{settings.environment}.log", 'a+')
      file = File.new("./log/web.log", 'a+')
      file.sync = true
      use Rack::CommonLogger, file
    end

  end
end

enable :sessions

get '/' do
  erb :index
end

get '/info/:name' do
  "Hello #{params['name']}!"
  session['value'] = params['name'] || "test"
end

get "/user" do

end

post '/login' do
  request.body.rewind
  data = JSON.parse request.body.read
  user = Guet.new
  if user.login(data['user'], data['passwd'])
  # if user.login('1300250113', '11121225')
  # if true
    session['user'] = user.user
    session['passwd'] = user.passwd
    "1"
  else
    "0"
  end
end

get '/userinfo' do
  if session['user']
    user = Guet.new
    if user.login(session['user'],session['passwd'])
      content_type :json
      user.get_user_info.to_json
    end
  else
    "not login"
  end
end

get '/start' do
    content_type :json
    system("ruby auto_vote.rb #{session['user']} #{session['passwd']}").to_json
end

get '/logout' do
  session['user'] = nil if session['user'] != nil
end


not_found do
  'This is nowhere to be found'
end
