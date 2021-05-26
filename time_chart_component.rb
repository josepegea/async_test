require 'tk_component'
require_relative 'time_chart_bar'

class TimeChartComponent < TkComponent::Base

  attr_accessor :bars, :bar_height, :bar_separation, :bar_fill_color, :bar_outline_color

  def initialize(**props)
    super
    @bars = []
    @bar_height = props['bar_height'] || 20
    @bar_separation = props['bar_separation'] || 5
    @bar_fill_color = props['bar_fill_color'] || 'khaki3'
    @bar_outline_color = props['bar_outline_color'] || 'black'
    @last_bar_hash = {}
  end

  def render(p, parent_component)
    p.vframe(padding: "8", sticky: 'nsew', x_flex: 1, y_flex: 1) do |f|
      @canvas = f.canvas(width: 600, height: 600, sticky: 'nwes', x_flex: 1, y_flex: 1) do |cv|
        cv.on_mouse_down ->(e) { draw_help_line(e) }
      end
      f.hframe(sticky: 'sew', x_flex: 1, y_flex: 0) do |hf|
        hf.button(text: 'Redraw', on_click: ->(e) { redraw_chart })
        hf.label(text: "Total time: ")
        @total_time = hf.entry
        @message_line = hf.label(text: "", sticky: 'ew', anchor: 'e', x_flex: 1, y_flex: 0)
      end
    end
  end

  def add_bar(name:, start_time: Time.now.to_f, end_time: nil)
    bar = TimeChartBar.new(name: name, start_time: start_time, end_time: end_time)
    bars << bar
    @last_bar_hash[name] = bar
    redraw_chart
    Tk.update
    bar
  end

  def finish_bar(bar, end_time: Time.now.to_f)
    bar.finish(end_time)
    redraw_chart
    Tk.update
  end

  def add_step(name, tag, timestamp)
    if tag == 'START'
      add_bar(name: name, start_time: timestamp)
    elsif tag == 'END'
      bar = @last_bar_hash[name]
      raise "#{name}-#{tag}-#{timestamp} - Error: END without START" unless bar
      finish_bar(bar, end_time: timestamp)
    end
  end

  def reset
    self.bars = []
    redraw_chart
    Tk.update
  end

  def redraw_chart
    @canvas.native_item.delete('all')
    @base_time = bars.map(&:start_time).min
    @max_time = bars.map(&:end_time).compact.max || @base_time + 1000
    @x_factor = (@canvas.native_item.winfo_width - 20.0)  / (@max_time - @base_time)

    draw_ruler
    bars.each_with_index { |b, i| draw_bar(b, i) }

    @total_time.value = format_timestamp(@max_time)
  end

  def draw_help_line(event)
    x = event.mouse_x
    TkcLine.new(@canvas.native_item, [x, 0], [x, @canvas.native_item.winfo_height], fill: 'gray', tags: %w<help_line>)
  end

  def clear_help_lines
    @canvas.native_item.delete('help_line')
  end

  private

  def draw_ruler
    # Let's get the round time unit closer to chunk pixels
    chunk = 60
    time_for_chunk = x_to_time(chunk) - x_to_time(0)
    number_of_zeroes = time_for_chunk.to_i.to_s.length
    time_slot = 10 ** number_of_zeroes
    TkcRectangle.new(@canvas.native_item, [0, 0], [@canvas.native_item.winfo_width, bar_height], outline: 'gray')
    slot = 0
    while time_to_x(slot) < @canvas.native_item.winfo_width do
      if slot % time_slot == 0
        TkcLine.new(@canvas.native_item, [time_to_x(slot), bar_height], [time_to_x(slot), bar_height - 8], fill: 'gray')
        TkcText.new(@canvas.native_item, [time_to_x(slot), bar_height - 7],
                    text: format_timestamp(slot, 1), font: 'Helvetica 9', anchor: 's')
      else
        TkcLine.new(@canvas.native_item, [time_to_x(slot), bar_height], [time_to_x(slot), bar_height - 3], fill: 'gray')
      end
      slot += time_slot / 10
    end
  end

  def draw_bar(bar, index)
    y1 = 2 * bar_height + index * (bar_height + bar_separation)
    x1 = time_to_x(bar.start_time)
    y2 = y1 + bar_height
    x2 = bar.end_time ? time_to_x(bar.end_time) : x1 + 10
    rect = TkcRectangle.new(@canvas.native_item, x1, y1, x2, y2, fill: bar_fill_color, outline: bar_outline_color)
    TkcText.new(@canvas.native_item, x1 + 10, y1 + (y2 - y1) / 2, text: bar.name, anchor: 'w')
    rect.bind( "Enter", -> { highlight_bar(bar, rect) })
    rect.bind( "Leave", -> { unhighlight_bar(bar, rect) })
  end

  def time_to_x(time)
    10 + (time - @base_time) * @x_factor
  end

  def x_to_time(x)
    (x - 10) / @x_factor + @base_time
  end

  def format_timestamp(ts, decimals_for_seconds = 3)
    case
    when ts == 0
      return "0"
    when ts < 1000
      return format("%d ms", ts.to_i)
    else
      return format("%0.#{decimals_for_seconds}f s", ts / 1000.0)
    end
  end

  def highlight_bar(bar, rect)
    @canvas.native_item.itemconfigure(rect, width: 2)
    @message_line.native_item.text = "#{bar.name} - #{bar.finished? ? format_timestamp(bar.elapsed_time) : 'Unfinished'}"
  end

  def unhighlight_bar(bar, rect)
    @canvas.native_item.itemconfigure(rect, width: 1)
    @message_line.native_item.text = ""
  end
end
