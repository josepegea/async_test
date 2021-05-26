#!/usr/bin/env ruby

require_relative './trace'
require_relative './logic'

$down_queue = Queue.new
$up_queue = Queue.new

$threads = []

$threads << Thread.new do
  page_index = 1
  page_size = ARGV[0] || 2
  current_page = 1
  total_pages = nil
  begin
    trace("Read page #{current_page}") do
      page_data = get_from_api(page_index: page_index, page_size: page_size)
      $down_queue << page_data['data']
      total_pages ||= page_data['total_pages']
      current_page += 1
    end
  end while current_page <= total_pages
  $down_queue.close
end
$threads << Thread.new do
  while (data = $down_queue.pop)
    trace("Process page") do
      new_data = process_api_data(data)
      $up_queue << new_data
    end
  end
  $up_queue.close
end
$threads << Thread.new do
  while (data = $up_queue.pop) do
    trace("Upload data") do
      upload_results(data)
    end
  end
end
$threads.map(&:join)
