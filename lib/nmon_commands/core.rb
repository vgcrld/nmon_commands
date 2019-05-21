require 'nmon_commands/version'
require 'nmon_commands/gpefile'
require 'awesome_print'
require 'zlib'

module NmonCommands

  def self.get_file_list(customer, uuid)
    loc = "/share/prd01/process/#{customer}/archive/by_uuid/#{uuid}/*.{linux,aix}.gz"
    files = Dir.glob(loc).sort.map{ |f| GpeFile.new(f) }
    return files
  end

  def self.filter_by_dates(files,start_ts,end_ts)
    if start_ts.nil?
      sts = (DateTime.now - 1).strftime('%s')
    else
      sts = DateTime.parse(start_ts).strftime('%s')
    end
    if end_ts.nil?
      ets = DateTime.now.strftime('%s')
    else
      ets = DateTime.parse(end_ts).strftime('%s')
    end
    ret = files.select { |file| file.between?(sts,ets) }
    return ret
  end

end
