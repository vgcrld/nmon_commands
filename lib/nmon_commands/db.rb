require 'yaml'
require 'awesome_print'
require 'optimist'
require 'csv'
require 'json'
require 'nmon_commands/setup'

module NmonCommands; module DB

  DB = YAML.load(File.new(File.join(VAR,"gpe_process.yaml"),'r'))

  # Return *vals that are not in array
  def self.not_in(array, *vals)
    vals.select do |val|
      not array.index(val)
    end
  end

  # Return the values of type in DB (:name, :type, :uuid) for *idx (indexes)
  def self.customer_value(customer,type,*idx)
    types = DB[customer]['details'][type.to_sym]
    idx = (0..types.length-1).to_a if idx.empty?
    return types.values_at(*idx)
  end

  # Return all the types found in the DB
  def self.all_types
    return DB.values.map{ |o| o['details'][:type] }.flatten.uniq
  end

  # Return all types for the customer based on searching search with filter
  def self.get(customer,search,filter)
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

  # Return all the customers
  def self.all_customers
    return DB.keys
  end

  # Return a summary of all the types in the DB
  def self.types
    DB.values.map{ |o| o['details'][:type] }.flatten.uniq.sort
  end

  # Convert the results to a CSV
  def self.to_csv(data)
    return nil if data.empty?
    rows = []
    data.first.each_index do |i|
      row = []
      data.length.times do |c|
        row << data[c][i]
      end
      rows << row.to_csv
    end
    return rows
  end

end; end