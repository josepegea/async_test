#!/usr/bin/env ruby

require_relative './trace'
require_relative './logic'

begin
  threads = []
  threads << Thread.new do
    $data = trace("Read text") { read_text }
  end
  threads << Thread.new do
    $replacement = trace("Read replacement") { get_replacement }
  end
  threads.each { |thr| thr.join }
end
$results = trace("Replace") { process_data($data, $replacement) }
begin
  threads = []
  threads << Thread.new do
    trace("Save") { save_results($results) }
  end
  threads << Thread.new do
    trace("Upload") { upload_results($results) }
  end
  threads.each { |thr| thr.join }
end
