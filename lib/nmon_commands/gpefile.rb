require 'json'
require "date"

class GpeFile

  attr_reader :filename, :date

  include Comparable

  def initialize(filename)
    @filename = filename
    @date     = make_date(filename)
  end

  def to_s
    return @filename
  end

  def get_table(interval)
    rows = grep_file_rows(interval.to_s)
    return rows
  end

  # Implement for comparable
  def <=>(cdate)
    @date <=> cdate
  end

  #builds an object with file and interval information
  def file_intervals
    intervals = get_all_intervals
    rows = grep_file_rows
    parts = self.filename.split("/")
    rows.map do |o|
      interval = (o.split(",",3)[1])
      {
        interval: interval,
        interval_date: intervals[interval],
        file_date: Time.at(self.date),
        file_epoch: self.date,
        fullpath: self.filename,
        filename: parts.last,
        uuid: parts[7]
      }
    end
  end

  ## scans a file and returns array of intervals
  def get_all_intervals
    lines = grep_file_rows('ZZZZ,T')
    ret = {}
    lines.map do |o|
      o.chomp!
      keys = o.split(",")
      ret[keys[1]] = "#{keys[3]} #{keys[2]}"
    end
    ap ret
    return ret
  end

  #scans a file line by line and only selects them if they match search
  def grep_file_rows(search='EXTERNAL-(aix|linux)-process,T')
    file = File.new(self.filename)
    gz = Zlib::GzipReader.new(file)
    return gz.read.lines.select{ |o| o.match(Regexp.new(search)) }
  end

  def ps_data_by_T_time
    data = self.grep_file_rows
    ret = {}
    data.each do |timeslice|
      data = timeslice.split('\n')
      trash, ts, headers  = data.shift.split(',')
      ret[ts] = []
      ret[ts] << headers.split.join(',')
      data.each do |psdata|
        ret[ts] << psdata.split(" ",13)
      end
    end
    return ret
  end

  def ps_data
    intervals = get_all_intervals
    data = self.grep_file_rows
    ret = []
    data.each_with_index do |timeslice, i|
      data = timeslice.split('\n')
      trash, ts, headers  = data.shift.split(',')
      data[0..-2].each do |psdata|
        row = psdata.split(" ",13)
        row_hash = {}
        row_hash["time"] = intervals[ts].split[1]
        headers.split.each_with_index do |o,i|
          row_hash[o] = row[i]
        end
        ret << row_hash
      end
    end
    return ret
  end

  private


  def make_date(filename)
    matcher = /^.*\.(\d{8})\.(\d{6})\.(\w{3})__.*/
    ts = File.basename(filename).match(matcher).captures.join(' ')
    ret = DateTime.strptime(ts,'%Y%m%d %H%M%S %Z').strftime('%s').to_i
    return ret
  end

end
