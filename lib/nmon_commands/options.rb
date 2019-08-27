
require 'optimist'

class Options

  def initialize

    @opts = Optimist::options do
      opt :customer, "Customer",   type: :string, required: true
      opt :uuid,     "UUID",       type: :string, required: true
      opt :limit,    "Limit",      type: :integer, default: 1
      opt :start,    "Start Date", type: :string
      opt :end,      "End Date",   type: :string
    end

  end

  def method_missing(cmd,*args)
    @opts[cmd]
  end

end


