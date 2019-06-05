require 'sinatra'
require 'awesome_print'
require 'json'

module NmonCommands

  class Viewer < Sinatra::Base

    get '/view/:customer/:uuid' do
      customer = params[:customer]
      uuid = params[:uuid]
      files = NmonCommands.get_file_list(customer,uuid)
      files.first.to_json
    end

    get '/customer' do
      Dir.glob('/Users/rdavis/process/*').map{ |o| File.basename(o) }.to_json
    end

    get '/customer/:customer/uuid' do
      customer = params[:customer]
      uuid = params[:uuid]
      Dir.glob("/Users/rdavis/process/#{customer}/archive/by_uuid/*").map do |dir|
        File.basename(dir)
      end.to_json
    end


  end

end
