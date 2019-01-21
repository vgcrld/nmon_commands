require 'nmon_commands/version'
require 'awesome_print'
require 'zlib'

module NmonCommands

  def self.get(filenames,search='EXTERNAL-linux-process,T')
    ret = {}
    return ret if filenames.nil?
    filenames = [ filenames ] if filenames.is_a?(String)
    filenames.map do |f|
      file = File.new(f)
      gz = Zlib::GzipReader.new(file)
      data = gz.read.lines.select do |o|
        o.match(Regexp.new(search))
      end
      ret[f] = data.flatten.map{ |o| o.split('\n') }
    end
    return ret
  end

  def self.get_file_list(customer,uuid)
    loc = "/share/prd01/process/#{customer}/archive/by_uuid/#{uuid}/*.linux.gz"
    files = Dir.glob(loc)
    return files
  end

end
