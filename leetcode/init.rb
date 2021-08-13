#! /usr/bin/ruby

require 'xcodeproj'
require_relative './log_color'
require_relative './create_proj'

append = ARGV.first
type = ''
# e,m,h | easy,meduim,hard
if append.nil?
    type = 'easy'
else
    if append == 'e' || append == 'easy'
        type = 'easy'
    elsif append == 'm' || append == 'meduim'
        type = 'meduim'
    elsif append == 'h' || append == 'hard'
        type = 'hard'
    else
        type = append.to_s
    end
end

puts "Current difficulty is " + color_text("[#{type}]", Color.white)

puts ">>> Input topic name:"
# [解决 ARGV 和 gets 一起使用的问题]https://blog.csdn.net/ye_i_qi/article/details/51775992 
name = $stdin.gets.chomp


# 选择创建 playground 还是 xcodeproj
puts <<DESC
Create source code by:
1、playground
2、xcodeproj

>>> Select a number to create the project:
DESC

proj_type = $stdin.gets.chomp

if proj_type.to_i == 1 
    puts "You select " + color_text('playground', Color.white) + " to create the project"
elsif proj_type.to_i == 2
    puts "You select " + color_text('xcodeproj', Color.white) + " to create the project"
else
    puts "Unknow type: " + color_text("#{proj_type}", Color.red)
    exit 1
end

cur_path = Dir.pwd + '/topics/'

# 判断是否存在这个路径，没有则创建
if not File.exist? cur_path
    Dir.mkdir cur_path
end

puts "Current path: #{cur_path}"

# 遍历当前文件夹，取出目前最大的topic数
max = 0
Dir.foreach(cur_path) do |x|
    if x == '.' or x == '..'
        next
    end
    if File.directory?(cur_path + "/#{x}") and x.match('topic*')
        #topic-x：-> topic-x
        topic = x.split("：").first
        n = topic.sub('topic-', '')
        if n.to_i > max.to_i 
            max = n
        end
    end
end

target_dir_path = cur_path + "topic-#{max.to_i+1}：[#{type}]#{name}"
Dir.mkdir(target_dir_path)

puts "Create dir named: #{name} success!"

create_proj(target_dir_path, proj_type)
