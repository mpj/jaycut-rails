# This assumes that you have put jaycut.rb in /lib or any other directory in your rails path.
require 'jaycut'

class ExampleController < ApplicationController
 
  def test 
	  key = 'PUT-YOUR-API-KEY-HERE' 
	  secret = 'PUT-YOUR-API-SECRET-HERE' 
	  factory = JayCutCommandFactory.new('PUT-YOUR-SITE-NAME-HERE', key, secret)
	  command = factory.create('PUT', '/users/charlie') 	
	  @login_url = command.uri_with_authentication_and_login
  end

end
