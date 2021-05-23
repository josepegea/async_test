#!/usr/bin/env ruby

require 'async'
require 'async/scheduler'

require_relative './trace'
require_relative './logic'

$data = read_text

Async do
  5.times do |idx|
    Async do
      trace("Task #{idx}") { process_data($data.dup, 'test') }
    end
  end
end
