require 'nmon_commands/version'
require 'nmon_commands/gpefile'
require 'awesome_print'
require 'zlib'

module NmonCommands

  def self.get(filenames,search='EXTERNAL-(aix|linux)-process,T')
    ret = {}
    return ret if filenames.nil?
    filenames = [ filenames ] if filenames.is_a?(String)
    filenames.map do |f|
      file = File.new(f.filename)
      gz = Zlib::GzipReader.new(file)
      data = gz.read.lines.select do |o|
        o.match(Regexp.new(search))
      end
      ret[f] = data.flatten.map{ |o| o.split('\n') }
    end
    return ret
  end

  def self.get_file_list(customer, uuid)
    loc = "/share/prd01/process/#{customer}/archive/by_uuid/#{uuid}/*.{linux,aix}.gz"
    files = Dir.glob(loc).sort.map{ |f| GpeFile.new(f) }
    return files
  end

  def self.filter_by_dates(files,start_ts,end_ts)
    sts = DateTime.parse(start_ts).strftime('%s')
    ets = DateTime.parse(end_ts).strftime('%s')
    ret = files.select { |file| file.between?(sts,ets) }
    return ret
  end

end
