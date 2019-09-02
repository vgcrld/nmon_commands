require 'nmon_commands/version'
require 'nmon_commands/gpefile'
require 'awesome_print'
require 'zlib'
require "json"

module NmonCommands

  def self.get_file_list(customer, uuid, start_ts: nil, end_ts: nil)
    loc = "/Users/joedavis/share/prd01/process/#{customer}/archive/by_uuid/#{uuid}/*.{linux,aix}.gz"
    files = Dir.glob(loc).sort.map{ |f| GpeFile.new(f) }
    files = filter_by_dates(files,start_ts,end_ts)
    return files
  end

  def self.get_customers
    Dir.glob("/Users/joedavis/share/prd01/process/*").map do |o|
      { name: File.basename(o), id: File.basename(o) }
    end.to_json
  end
  
  def self.get_uuid(customer)
    Dir.glob("/Users/joedavis/share/prd01/process/#{customer}/archive/by_uuid/*").map do |o|
      { name: File.basename(o), id: File.basename(o) }
    end.to_json
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
