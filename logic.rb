require 'net/http'
require 'uri'
require 'json'

def read_text
  Net::HTTP.get(URI 'https://www.gutenberg.org/files/2600/2600-0.txt')
end

def get_replacement
  res = Net::HTTP.get(URI "https://reqres.in/api/words/1")
  res = JSON.parse(res)&.fetch('data')&.fetch('name')
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

def get_from_api(page_index: 1, page_size: 2)
  res = Net::HTTP.get(URI "https://reqres.in/api/words?page=#{page_index}&per_page=#{page_size}")
  res = JSON.parse(res)
end

def process_api_data(data)
  res = ""
  1000.times { res += data.to_json }
  res
end
