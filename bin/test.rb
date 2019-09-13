
require 'awesome_print'
require 'nmon_commands'

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
