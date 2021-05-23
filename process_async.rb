#!/usr/bin/env ruby

require 'async'
require 'async/scheduler'

require_relative './trace'
require_relative './logic'

Async do
  Async do
    $data = trace("Read text") { read_text }
  end
  Async do
    $replacement = trace("Read replacement") { get_replacement }
  end
end
$results = trace("Replace") { process_data($data, $replacement) }
Async do
  Async do
    trace("Save") { save_results($results) }
  end
  Async do
    trace("Upload") { upload_results($results) }
  end
end
