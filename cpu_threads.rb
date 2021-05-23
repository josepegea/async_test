#!/usr/bin/env ruby

require_relative './trace'
require_relative './logic'

$data = read_text

threads = []

5.times do |idx|
  threads << Thread.new do
    trace("Task #{idx}") { process_data($data.dup, 'test') }
  end
end
threads.each { |thr| thr.join }
