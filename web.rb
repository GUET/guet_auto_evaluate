require 'rubygems'
require 'sinatra'
require 'json'

module Sinatra
  class Base
    set :server, %w[thin mongrel webrick]
    set :bind, '0.0.0.0'
    set :port, 8000
    set :views, File.dirname(__FILE__) + '/views'
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
  require_relative 'User'
  @user = User.new(data['user'], data['passwd'])

  if @user.login
  # if true
    session['user'] = @user.user
    "1"
  else
    "0"
  end
end

get '/logout' do
  session[:user] = nil if session[:user] != nil
end


not_found do
  'This is nowhere to be found'
end

