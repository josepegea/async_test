#!/usr/bin/env ruby

require_relative './trace'
require_relative './logic'

$page_index = 1
$page_size = ARGV[0] || 2

$current_page = 1
$total_pages = nil

begin
  page_data = trace("Read page #{$current_page}") do
    get_from_api(page_index: $page_index, page_size: $page_size)
  end
  $total_pages ||= page_data['total_pages']
  new_data = trace("Process page #{$current_page}") do
    process_api_data(page_data['data'])
  end
  trace("Upload data #{$current_page}") do
    upload_results(new_data)
  end
  $current_page += 1
end while $current_page <= $total_pages
