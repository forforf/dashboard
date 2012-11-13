module Dashboard
  class Server < Sinatra::Base
    set :root, File.dirname(Dashboard::ROOT)
    set :public, Proc.new { File.join(root, "public") }
    
    #configure do
      # set app specific settings
      # for example different view folders
    #end
    
    get '/api_proxy' do
      "Hello from foo, ROOT is #{settings.root}"
    end
    
    # I did this to be able to wrap my app in Rack::Auth::Digest for example
    ## Example:
    ## def self.new(*)
    ##  app = Rack::Auth::Digest::MD5.new(super) do |username|
    ##    {'foo' => 'bar'}[username]
    ##  end
    ##  app.realm = 'Foobar::Foo'
    ##  app.opaque = 'secretstuff'
    ##  app
    ## end   
    
    def self.new(*)
      super
    end
    
  end
end
