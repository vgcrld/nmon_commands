require 'json'

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
    ap rows
    return rows
  end

  #currently not in use
  def get_data(start_ts)
    ret = {}
    rows = grep_file_rows
    rows.each_with_index do |sample,i|
      lines = sample.lines('\n')
      t, samp, head = lines.shift.split(",",3)
      ret[:title] = DateTime.strptime(date.to_s, "%s")
      ret[:header] = head.chomp('\n').split(" ",13)
      ret[samp] = lines.map do |o|
        line = o.chomp!('\n')
        next if line.nil?
        [ line.split(" ",13) ].flatten
      end.compact
    end
    return ret
  end

  # Implement for comparable
  def <=>(cdate)
    @date <=> cdate
  end

  #builds an object with file and interval information
  def file_intervals
    intervals = get_all_intervals
    rows = grep_file_rows
    rows.map do |o|
      interval = (o.split(",",3)[1])
      {
        interval: interval,
        interval_date: intervals[interval],
        file_date: Time.at(self.date),
        file_epoch: self.date,
        file: self.filename
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
    return ret
  end

  #scans a file line by line and only selects them if they match search
  def grep_file_rows(search='EXTERNAL-(aix|linux)-process,T')
    file = File.new(self.filename)
    gz = Zlib::GzipReader.new(file)
    return gz.read.lines.select{ |o| o.match(Regexp.new(search)) }
  end

  private


  def make_date(filename)
    matcher = /^.*\.(\d{8})\.(\d{6})\.(\w{3})__.*/
    ts = File.basename(filename).match(matcher).captures.join(' ')
    ret = DateTime.strptime(ts,'%Y%m%d %H%M%S %Z').strftime('%s').to_i
    return ret
  end

end
