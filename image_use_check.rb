
inputs = ARGV

search_path = ''

if inputs.count > 0 
    search_path = inputs.first
else
    search_path = Dir.pwd
end

