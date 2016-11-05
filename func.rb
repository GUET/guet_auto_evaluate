require 'rubygems'
require 'sinatra'
require 'json'

module Sinatra
  class Base
    set :server, %w[thin mongrel webrick]
    set :bind, '0.0.0.0'
    set :port, 8000
    set :views, File.dirname(__FILE__) + '/views'
    set :environment, :production
    set :logging, true
  end
end



get '/' do
  /xxx
end

get '/info' do
  user = User.new
  user.login
  user.info
end

get '/sxxx' do
  user = User.new
  user.login
  user.info
end
