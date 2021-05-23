def timestamp
  Time.now.to_f
end

def trace(name, &block)
  puts("#{name}\tSTART\t#{timestamp}")
  res = block.call
  puts("#{name}\tEND\t#{timestamp}")
  res
end
