require 'sinatra'
require 'sinatra/cross_origin'
require 'awesome_print'
require 'json'
require 'haml'
require "date"
require "uri"

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
        enable :sessions
      end

      before do
        response.headers['Access-Control-Allow-Origin'] = '*'
      end

      run!
    end

    # Pages
    get '/view' do
      haml :view
    end

    # endpoints - return uuids for a customer
    get "/uuid/:customer" do
      customer = params[:customer]
      uuids = NmonCommands.get_uuid(customer)
      session[customer] = { uuids: uuids }
      uuids
    end

    # Return files for a custoerm:uuid:start:end
    get "/getfile/:customer/:uuid/:start_ts/:end_ts" do
      start_time = params[:start_ts].to_i/1000
      end_time = params[:end_ts].to_i/1000
      NmonCommands.get_file_list(params[:customer], params[:uuid], start_time, end_time)
    end

    # Return the time intervals
    get "/getdates/:customer/:uuid/:start_ts/:end_ts" do
      start_time = params[:start_ts].to_i/1000
      end_time = params[:end_ts].to_i/1000
      files = NmonCommands.get_file_list(params[:customer], params[:uuid], start_time, end_time)
      times = NmonCommands.get_intervals(files)
      times.to_json
    end

    # Return the table ps data from the file
    get "/gettable/:interval/:id/*" do
      interval = params[:interval]
      id = params[:id]
      file_path = params[:splat][0]
      #working just returing a single table
      #the grep_file_rows File.open method is not finding the file even though its there
      #table = GpeFile.new(file_path)
      #rows = table.get_table(interval)
      #return for testing
      {name: interval, file_path: file_path, id: id}.to_json
    end


    # Test page
    get '/doc' do
      haml :doc
    end

    # Set Sinatra options to allow CORRS
    options "*" do
      response.headers["Allow"] = "GET, PUT, POST, DELETE, OPTIONS"
      response.headers["Access-Control-Allow-Headers"] = "Authorization, Content-Type, Accept, X-User-Email, X-Auth-Token"
      response.headers["Access-Control-Allow-Origin"] = "*"
      200
    end

  end

end
