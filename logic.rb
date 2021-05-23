require 'net/http'
require 'uri'
require 'json'

def read_text
  res = Net::HTTP.get(URI 'https://www.gutenberg.org/files/2600/2600-0.txt')
  STDERR.puts "Text length is #{res.length}"
  res
end

def get_replacement
  res = Net::HTTP.get(URI "https://reqres.in/api/words/1")
  res = JSON.parse(res)&.fetch('data')&.fetch('name')
  STDERR.puts "Replacement is #{res}"
  res
end

def process_data(data, replacement)
  %w<white light clear snowy gray grey silver>.each do |color|
    data = data.gsub(color, replacement)
  end
  data
end

def save_results(results)
  File.write('/tmp/replaced.txt', results * 10);
end

def upload_results(data)
  Net::HTTP.post(URI("https://reqres.in/api/texts"), data[0, 1024])
end

