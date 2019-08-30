require 'sinatra'
require 'awesome_print'
require 'json'
require 'haml'

module NmonCommands

  class Viewer < Sinatra::Base

    def self.start(config)
      # Configure Sinatra
      set :port, config.port
      set :bind, config.bind
      set :run, config.run
      set :views, config.views
      set :public_folder, config.public
      run!
    end

    # View a file
    get '/view' do
      haml :view
    end

    # Information
    get '/doc' do
      haml :doc
    end

  end

end
