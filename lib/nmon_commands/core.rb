require 'nmon_commands/gpefile'
require 'awesome_print'
require 'zlib'
require "json"
require "date"

module NmonCommands

  #takes array of file strings and returns the intervals
  def self.get_intervals(files)
    return files.map{ |file| file.file_intervals }.flatten
  end

  #takes file location and pulls the ones in the correct time
  def self.get_file_list(customer, uuid, start_ts, end_ts)
    loc = "/share/prd01/process/#{customer}/archive/by_uuid/#{uuid}/*.{linux,aix}.gz"
    files = Dir.glob(loc).sort.map{ |f| GpeFile.new(f) }
    filtered = filter_by_dates(files,start_ts,end_ts)
    return filtered
  end

  #takes a list of files and returns the ones in a right time interval
  def self.filter_by_dates(files,start_ts,end_ts)
    return files.select{ |file| file.between?(start_ts,end_ts) }
  end

  #for retuning customer list get request
  def self.get_customers
    DB.all_customers.map do |o|
      { name: File.basename(o), uuid: File.basename(o), title: File.basename(o) }
    end.to_json
  end

  #for returning uuid list get request
  def self.get_uuid(customer)
    customers, hosts, types, uuids = DB.get(customer,:type,'aix|linux')
    uuids.map do |o|
      uuid = File.basename(o)
      { name: uuid, uuid: uuid }
    end.compact.to_json
  end

end
