lines = [20_000]

lines.each do |line|
  `head -n #{line} data/data_large.txt > data/data_#{line}_lines.txt`
end
