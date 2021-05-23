#!/usr/bin/env ruby

require_relative './trace'
require_relative './logic'

$data = read_text.freeze

ractors = []

5.times do |idx|
  ractors << Ractor.new(idx, $data) do |i, data|
    trace("Task #{i}") { process_data(data, 'test') }
  end
end
ractors.map(&:take)
