#!/usr/bin/env ruby

require_relative './trace'
require_relative './logic'

$data = trace("Read text") { read_text }
$replacement = trace("Get replacement") { get_replacement }
$results = trace("Replace") { process_data($data, $replacement) }
trace("Save") { save_results($results) }
trace("Upload") { upload_results($results) }

