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

  def <=>(cdate)
    @date <=> cdate
  end

  def make_date(filename)
    matcher = /^.*\.(\d{8})\.(\d{6})\.(\w{3})__.*/
    ts = File.basename(filename).match(matcher).captures.join(' ')
    DateTime.strptime(ts,'%Y%m%d %H%M%S %Z').strftime('%s')
  end
end
