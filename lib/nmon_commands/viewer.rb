require 'sinatra'

module NmonCommands

  class Viewer < Sinatra::Base

    get '/' do
      'this is working'
    end

  end

end
