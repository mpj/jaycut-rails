# JayCutCommandFactory is a factory that can
# create JayCutCommands.
class JayCutCommandFactory
	  attr_accessor :site_name, :key, :secret, :api_host_base

	  def initialize(site_name, key, secret)
		  @site_name = site_name
		  @key =  key
		  @secret = secret
		  @api_host_base = "api.jaycut.com"
	  end

    # Creates (but does not run) a certain command. 
    # Example: factory.create("PUT", "/users/wayne.gretzky")
	  def create(method, path)
		  JayCutCommand.new(self, method, path)		
	  end
	  
end

# JayCutCommand represents a command to the API. 
#
# You can either call the run method on it, or return the
# uri for the command (which you might want to give to the web client,
# so that it can issue commands on it's own)
class JayCutCommand
		attr_accessor :factory, :method, :path, :expires

    # Creates a command. Called by JayCutCommandFactory.create
    # and should not be called directly.
		def initialize(factory, method, path)
      
			raise "Path must begin with slash." if path[0] != 47
			raise "Factory cannot be nil" if factory.nil?
			raise ArgumentError, "Method must be PUT, DELETE, GET or POST", method if not is_restful(method)
	
			@factory = factory
			@method = method.upcase
			@path = path		
			@expires = Time.now.to_i + 3600		
		end

    # Returns the base uri for the command.
    # Example: "http://dogcatvideosite.api.jaycut.com/users/wayne.gretzky"
		def base_uri			
			URI.parse( "http://" + @factory.site_name + "." + @factory.api_host_base + @path )
		end

    # Returns the uri for the command, including authentication query string.
    # Example: 
    # http://dogcatvideosite.api.jaycut.com/users/wayne.gretzky?api_key=7JAMd9Xsiz5&signature=a45asd8sda784f1c7fe4cd1s5a4ds84das5d5as4&expires=451511512145
		def uri_with_authentication			
			uri = base_uri.to_s + "?" + query_string
			method_hack = "&_method=" + @method 
			# some clients (such as flash, and explorer) have an issue with PUT and delete methods. 
			# method_hack insures that the right method gets through.
			URI.parse( uri + method_hack )
		end
    
    # Same as uri_with_authentication, but also includes a &login=true parameter, 
    # which will cause a session a cookie to be set on the the client, 
    # which means that subsequent requests from the client won't need to send authentication data.
		def uri_with_authentication_and_login
			URI.parse( uri_with_authentication.to_s + "&login=true" )
		end
		
		# Runs the command against the JayCut API.
		def run
			req = Net::HTTP::Put.new(uri.path)
			req.body = query_string
			res = Net::HTTP.start(url.host, url.port) { |http|
			  http.request(req)
			}
			res.body
		end

    private   
    
		def query_string						  
			"api_key=" + @factory.key  + 
			"&signature=" + generate_security_signature() + 
			"&expires=" + @expires.to_s								
		end	

		def generate_security_signature() 		  
			base = @factory.secret + @method + @path + @expires.to_s
			RAILS_DEFAULT_LOGGER.debug base
			Digest::SHA1.hexdigest base	
		end
		
		def is_restful(method)
		  method.upcase == "PUT" or 
		  method.upcase == "GET" or 
		  method.upcase == "POST" or 
		  method.upcase == "DELETE"
		end
		
end