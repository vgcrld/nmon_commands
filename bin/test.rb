#!/bin/env ruby

require 'awesome_print'
require 'nmon_commands'


db = NmonCommands::DB

# Return all the customers
# ap db.all_customers

# Return all the types (aix, linux, oracle, etc)
# ap db.all_types

# Return lists of data. Search :type, :name, or :uuid
# ap db.get('PSU',:type,'linux')         # Get all PSU Linux system data
# ap db.get('PSU',:type,'aix')           # Get all PSU Linux system data
# ap db.get('PSU',:name,'tr21n11a')      # Get all PSU systems named tr21n1aa
# ap db.get('PSU',:name,'^tr(16|26)')    # Get all PSU systems starting with name tr16 or tr26

# Search (like get) but return the GpeFiles. reseut is uuid => [ gpefile1, gpefile2, ... ]
# ap db.get_files_for_customer_with_search('PSU',:type,'linux')

# How to limit by time
# ap db.get_files_for_customer_with_search('PSU',:name,'tr2[16]').values.flatten.select{ |o| o >= Time.now.to_i-7200 }
#

# How to zip up
header = %w(customer name type uuid)
data = NmonCommands::DB.get('atsgroup',:type,/aix/i)
start = data.shift
rows = start.zip(*data).map{ |o| CSV::Row.new(header,o) }
table = CSV::Table.new(rows)



exit


HOURS = 2

cust = 'atsgroup'
uuid = 'f2C6b5Ce-Ff95-451a-b11C-9aF1a486ebe2'
st = Time.now.to_i - (60*60*HOURS)
et = Time.now.to_i

ap "From Start: #{Time.at(st)}"
ap "From End:   #{Time.at(et)}"

files = NmonCommands.get_file_list(cust, uuid, st, et)
times = NmonCommands.get_intervals(files)

ap times
