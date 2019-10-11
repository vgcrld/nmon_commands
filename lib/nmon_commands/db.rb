require 'yaml'
require 'awesome_print'
require 'optimist'
require 'csv'
require 'json'
require 'nmon_commands/setup'

module NmonCommands; module DB

  DB = YAML.load(File.new(File.join(VAR,"gpe_process.yaml"),'r'))

  # @param [String] customer - exact name of custmer
  # @param [Symbol] type - set search column: :name, :uuid, or :type (default :type)
  # @param [Regexp] filter- filter search for  (default is /linux|aix/)
  # @param [String] limit - glob filter spec (default is "*.{linux,aix}")
  # Return [Hash] uuid => [Array] [GpeFile]
  def self.get_files_for_customer_with_search(customer,search=:type,filter=/aix|linux/,limit='*.gz')
    ret = {}
    path = DB[customer]["path"]
    data = get(customer,search,filter)
    paths = data[3].each_with_index.map do |o,i|
      glob = File.join(path,o,limit)
      ret[o] = Dir.glob(glob).map{ |gpe| GpeFile.new(gpe) }
    end
    return ret
  end

  # @param [String] customer - exact name of custmer
  # @param [Symbol] type - set search column: :name, :uuid, or :type (default :type)
  # @param [Regexp] limit - filter search for  (default is /linux|aix/)
  # Return [Array] len of 4 each being an array of customer,name,type,uuid
  def self.get(customer,search=:type,filter=/aix|linux/)
    data = DB[customer]['details'][search]
    idx = data.map.each_with_index{ |o,i| i if o.match(filter)}.compact
    len = idx.length
    return [] if idx.empty?
    return [
      Array.new(len,customer),
      customer_value(customer,:name,*idx),
      customer_value(customer,:type,*idx),
      customer_value(customer,:uuid,*idx)
    ]
  end

  # Return all the customer names
  def self.all_customers
    return DB.keys
  end

  # @param [String] customer - exact name of custmer
  # @param [Symbol] type - set search column: :name, :uuid, or :type
  # @param [Regexp] limit - search for  (default is /linux|aix/)
  # Return an [Array] of [Hashes] with customer, name, type, uuid keys [String]
  def self.get_detail_hash_for_customer(customer, type: :type, limit: /linux|aix/)
    table = self.get(customer,type,limit)
    csv = self.to_csv(table)
    return csv.map{ |o| o }
  end

  # Return an [Array] of all the types found in the DB
  def self.all_types
    return DB.values.map{ |o| o['details'][:type] }.flatten.uniq.sort
  end

  # Return the values of type in DB (:name, :type, :uuid) for *idx (indexes)
  def self.customer_value(customer,type,*idx)
    types = DB[customer]['details'][type.to_sym]
    idx = (0..types.length-1).to_a if idx.empty?
    return types.values_at(*idx)
  end

  # Return *vals that are not in array
  def self.not_in(array, *vals)
    vals.select do |val|
      not array.index(val)
    end
  end

  # Convert the results to a CSV
  # data is a an array of equally sized arrays
  # Return is a CSV::Table
  def self.to_csv(data)
    return nil if data.empty?
    header = %w(customer name type uuid)
    start = data.shift
    zipped = start.zip(*data)
    rows = zipped.map{ |o| CSV::Row.new( header, o ) }
    table = CSV::Table.new(rows)
    return table
  end

end; end
