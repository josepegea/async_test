#!/usr/bin/env ruby

require 'tk_component'

require_relative 'time_chart_component'

$base_time = nil

def process_line(l)
  name, tag, duration = l.split("\t")
  duration = duration.to_f
  $base_time ||= duration
  $chart.add_step(name, tag, (duration - $base_time) * 1000)
end

$title = ARGV[0] || "Results"
root = TkComponent::Window.new(title: $title, root: true)
$chart = TimeChartComponent.new
root.place_root_component($chart)
Tk.update

while (l = STDIN.gets) do
  process_line(l)
end

Tk.mainloop
