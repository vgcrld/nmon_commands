require 'sinatra'
require 'awesome_print'
require 'json'
require 'haml'
require "date"

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

    get "/uuid/:customer" do
      NmonCommands.get_uuid(params[:customer])
    end

    get "/getfile/:customer/:uuid/:start_ts/:end_ts" do
        NmonCommands.get_file_list(params[:customer], params[:uuid], params[:start_ts], params[:end_ts])
    end

    # Information
    get '/doc' do
      haml :doc
    end

  end

end
