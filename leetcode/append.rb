#！/usr/bin/ruby

require 'xcodeproj'
require_relative './log_color'
require_relative './create_proj'

# 选择一个 topic ，往其中加入新工程

append = ARGV.first
# -a 列出所有‘topic’
# -n 列出最近的一个’topic‘

if not append.nil?
    if append != '-a' and append != '-n'
        puts "Unknow append character " + color_text(append, Color.red)
    
puts <<EOF
You can append a optional param with '-a' or '-n'.
-a: list all topics
-n: list lastest topic
EOF
        exit 1
    end
end

cur_path = Dir.pwd + '/topics/'

entrys = Array.new
entrys[1] = "12"

Dir::glob("topics/topic-*") do |item|
    # topics/topic-23：Convert Sorted Array to Binary Search Tree   
    topic_string = item.split("：")
    topic_num = topic_string.first
    n = topic_num.sub('topics/topic-', '').to_i
    entrys[n-1]= "#{n}：" + topic_string.last
end

topic_name = ''
num = 0
if append == '-a'
    puts entrys

    while true do 
        puts ">>> Input a number to select a topic to insert the new project"
        num = $stdin.gets.chomp 
        if num.to_i > entrys.count
            puts "Out of range " + color_text("{1, #{entrys.count}}", Color.red)
        else
            topic_name = entrys[num.to_i - 1].split('：').last
            break
        end
    end
else
    num = entrys.last.split('：').first
    topic_name = entrys.last.split('：').last
end

puts "You will insert a new project to topic：" + color_text(topic_name, Color.green)


# 选择创建 playground 还是 xcodeproj
puts <<DESC

Create source code by:
1、playground
2、xcodeproj

>>> Select a number to create the project:
DESC

proj_type = $stdin.gets.chomp

target_dir_path = cur_path + "topic-#{num}：" + topic_name

create_proj(target_dir_path, proj_type)