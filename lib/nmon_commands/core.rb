require 'nmon_commands/version'
require 'nmon_commands/gpefile'
require 'awesome_print'
require 'zlib'
require "json"
require "date"

module NmonCommands

  def self.get_dates(customer, uuid, start_ts, end_ts)
    loc = "/share/prd01/process/#{customer}/archive/by_uuid/#{uuid}/*.{linux,aix}.gz"
    files = Dir.glob(loc).sort.map{ |f| GpeFile.new(f) }
    filtered = filter_by_dates(files,start_ts,end_ts)
    return filtered.map { |o| o.get_dates }.to_json
  end

  def self.get_file_list(customer, uuid, start_ts, end_ts)
    loc = "/share/prd01/process/#{customer}/archive/by_uuid/#{uuid}/*.{linux,aix}.gz"
    files = Dir.glob(loc).sort.map{ |f| GpeFile.new(f) }
    filtered = filter_by_dates(files,start_ts,end_ts)
    return filtered.map{ |o| o.get_data(start_ts) }.to_json
  end

  def self.filter_by_dates(files,start_ts,end_ts)
    return files.select{ |file| file.between?(start_ts,end_ts) }
  end

  def self.get_customers
    Dir.glob("/share/prd01/process/*").map do |o|
      { name: File.basename(o), id: File.basename(o), title: File.basename(o) }
    end.to_json
  end

  def self.get_uuid(customer)
    Dir.glob("/share/prd01/process/#{customer}/archive/by_uuid/*").map do |o|
      uuid = File.basename(o)
      { name: uuid, id: uuid } if uuid.match(/^[[:xdigit:]]{8}-([[:xdigit:]]{4}-){3}[[:xdigit:]]{8}/)
    end.compact.to_json
  end

end
