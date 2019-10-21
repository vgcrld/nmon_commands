require 'sinatra'
require 'sinatra/cross_origin'
require 'awesome_print'
require 'json'
require 'haml'
require 'date'
require 'uri'
require 'nmon_commands/db'

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

    get '/view' do
      haml :view
    end

    # Get all customers
    get "/api/v1/customer" do
      customers = NmonCommands::DB.all_customers
      customers.to_json
    end

    # Get a customer Details
    get "/api/v1/customer/:customer/details" do
      details = NmonCommands::DB.get_detail_hash_for_customer(params[:customer])
      details.to_json
    end


    # Return files for a customer:uuid:start:end
    get "/api/v1/customer/:customer/files/:uuid" do
      if params[:start_time].nil?
        start_time = (Time.now.to_i - 7200)
      else
        start_time = params[:start_time].to_i
      end
      if params[:end_time].nil?
        end_time = Time.now.to_i
      else
        end_time = params[:end_time].to_i
      end
      files = NmonCommands::DB.get_files_for_customer_with_search(params[:customer], params[:uuid])
      filtered = files.values.flatten.select{ |o| o >= start_time and o <= end_time }
      filtered.to_json
    end

    # Return the table ps data from the file
    get "/api/v1/customer/:customer/psdata" do
      file = GpeFile.new(params[:filename])
      ret = file.ps_data
      ret.to_json
    end

    options "*" do
      response.headers["Allow"] = "GET, PUT, POST, DELETE, OPTIONS"
      response.headers["Access-Control-Allow-Headers"] = "Authorization, Content-Type, Accept, X-User-Email, X-Auth-Token"
      response.headers["Access-Control-Allow-Origin"] = "*"
      200
    end

  end

end
