require 'sinatra'
require 'sinatra/cross_origin'
require 'awesome_print'
require 'json'
require 'haml'
require "date"

module NmonCommands

  class Viewer < Sinatra::Base

    def self.start(config)

      set :port, config.port
      set :bind, config.bind
      set :run, config.run
      set :views, config.views
      set :public_folder, config.public

      configure do
        enable :cross_origin
      end

      before do
        response.headers['Access-Control-Allow-Origin'] = '*'
      end

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
      start_time = params[:start_ts].to_i/1000
      end_time = params[:end_ts].to_i/1000
      NmonCommands.get_file_list(params[:customer], params[:uuid], start_time, end_time)
    end

    get "/getdates/:customer/:uuid/:start_ts/:end_ts" do
      start_time = params[:start_ts].to_i/1000
      end_time = params[:end_ts].to_i/1000
      files = NmonCommands.get_file_list(params[:customer], params[:uuid], start_time, end_time)
      times = NmonCommands.get_intervals(files)
      times.to_json
    end

    # Information
    get '/doc' do
      haml :doc
    end

    options "*" do
      response.headers["Allow"] = "GET, PUT, POST, DELETE, OPTIONS"
      response.headers["Access-Control-Allow-Headers"] = "Authorization, Content-Type, Accept, X-User-Email, X-Auth-Token"
      response.headers["Access-Control-Allow-Origin"] = "*"
      200
    end

  end

end
