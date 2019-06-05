require 'json'

class GpeFile

  attr_reader :filename, :date, :json

  include Comparable

  def initialize(filename)
    @filename = filename
    @date     = make_date(filename)
    @data     = nil
    @json     = nil
  end

  def to_s
    return @filename
  end

  def data
    @data = get_data if @data.nil?
  end

  def to_json
    ret = {}
    data.each_with_index do |sample,i|
      lines = sample.lines('\\n')
      t, samp, head = lines.shift.split(",",3)
      ret[:header] = head.chomp('\\n')
      ret[samp] = lines.map{ |o| o.chomp!('\\n') }
    end
    return  ret.to_json
  end

  def <=>(cdate)
    @date <=> cdate
  end

  private

  def get_data
    search='EXTERNAL-(aix|linux)-process,T'
    file = File.new(self.filename)
    gz = Zlib::GzipReader.new(file)
    return gz.read.lines.select{ |o| o.match(Regexp.new(search)) }
  end

  def make_date(filename)
    matcher = /^.*\.(\d{8})\.(\d{6})\.(\w{3})__.*/
    ts = File.basename(filename).match(matcher).captures.join(' ')
    DateTime.strptime(ts,'%Y%m%d %H%M%S %Z').strftime('%s')
  end



end
