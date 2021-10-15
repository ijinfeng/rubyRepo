
#! /usr/bin/ruby

require_relative './log_color'

options = "-a"
append = ARGV.first
if append == 'n' or append == '-n'
    options = "-n"
end

taget_dir_path = "/Users/zl/Developer/Project"
system("cd #{taget_dir_path}")
# 列出这个目录下的文件夹
paths = Array.new
entrys = Array.new
index = 0
Dir.foreach(taget_dir_path) do |x|
    if x == '.' or x == '..'
        next
    end
    if File.directory?(taget_dir_path + "/#{x}")
        paths[index] = taget_dir_path + "/#{x}"
        entrys[index] = "#{index+1}. #{x}"
        index += 1
    end
end

def open(filePath)
    system("ruby /Users/zl/Desktop/jinfeng/ruby/rubyRepo/openxc.rb #{filePath}")
end

save_select_proj_path = "/Users/zl/.plsfile"
if not File.exist? save_select_proj_path
    f=File.new(save_select_proj_path, 'w+')
    f.close
end

last_open_proj_path = ""
if options == '-n'
    File.open(save_select_proj_path, 'r') do |f|
        last_open_proj_path = f.read
    end
end

if last_open_proj_path.length > 0
    open last_open_proj_path
    exit 1
end

puts entrys

select_proj_path = ""
select_proj_name = ""
while true do
    puts color_text("Input a number to open a project：", Color.white)
    num = $stdin.gets.chomp
    if num.to_i > entrys.count or num.to_i <= 0
        puts "Out of range " + color_text("{1, #{entrys.count}}", Color.red)
    else
        select_proj_path = paths[num.to_i - 1]
        select_proj_name = entrys[num.to_i - 1]
        # 持久化之前选中的
        File.open(save_select_proj_path, 'w') do |f|
            f.write select_proj_path
        end
        break
    end
end
    
puts "You selected project named: " + color_text(select_proj_name, Color.green)

open select_proj_path


