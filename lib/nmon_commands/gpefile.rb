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

  def to_json
    ret = {}
    raw_data.each_with_index do |sample,i|
      lines = sample.lines('\n')
      t, samp, head = lines.shift.split(",",3)
      ret[:header] = head.chomp('\n').split(" ",13)
      ret[samp] = lines.map do |o|
        line = o.chomp!('\n')
        next if line.nil?
        [ head, o, line.split(" ",13) ].flatten
      end
    end
    return ret.to_json
  end

  def <=>(cdate)
    @date <=> cdate
  end

  def raw_data
    search='EXTERNAL-(aix|linux)-process,T'
    file = File.new(self.filename)
    gz = Zlib::GzipReader.new(file)
    return gz.read.lines.select{ |o| o.match(Regexp.new(search)) }
  end

  private

  def make_date(filename)
    matcher = /^.*\.(\d{8})\.(\d{6})\.(\w{3})__.*/
    ts = File.basename(filename).match(matcher).captures.join(' ')
    ret = DateTime.strptime(ts,'%Y%m%d %H%M%S %Z').strftime('%s')
    return ret
  end



end
