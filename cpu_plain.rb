#!/usr/bin/env ruby

require_relative './trace'
require_relative './logic'

$data = read_text

5.times do |idx|
  trace("Task #{idx}") { process_data($data.dup, 'test') }
end
