class TimeChartBar
  attr_accessor :name, :start_time, :end_time
  
  def initialize(name:, start_time: Time.now.to_f, end_time: nil)
    @name = name
    @start_time = start_time
    @end_time = end_time
  end

  def finish(end_time = Time.now.to_f)
    self.end_time = end_time
  end

  def finished?
    !!end_time
  end

  def elapsed_time
    finished? ? end_time - start_time : nil
  end
end
