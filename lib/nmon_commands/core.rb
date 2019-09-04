require 'nmon_commands/version'
require 'nmon_commands/gpefile'
require 'awesome_print'
require 'zlib'
require "json"

module NmonCommands

  def self.get_file_list(customer, uuid, start_ts, end_ts)
    loc = "/share/prd01/process/#{customer}/archive/by_uuid/#{uuid}/*.{linux,aix}.gz"
    files = Dir.glob(loc).sort.map{ |f| GpeFile.new(f) }
    files = filter_by_dates(files,start_ts,end_ts)
    return files
  end

  def self.get_customers
    Dir.glob("/share/prd01/process/*").map do |o|
      { name: File.basename(o), id: File.basename(o) }
    end.to_json
  end

  def self.get_uuid(customer)
    Dir.glob("/share/prd01/process/#{customer}/archive/by_uuid/*").map do |o|
      uuid = File.basename(o)
      { name: uuid, id: uuid } if uuid.match(/^[[:xdigit:]]{8}-([[:xdigit:]]{4}-){3}[[:xdigit:]]{8}/)
    end.compact.to_json
  end

  def self.filter_by_dates(files,start_ts,end_ts)
    ret = files.select{ |file| file.between?(start_ts,end_ts) }
    return ret
  end

end
