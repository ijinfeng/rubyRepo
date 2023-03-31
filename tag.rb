#!/usr/bin/ruby

# 打tag

now = Time.new
year = now.year
month = "%02d"% now.month
day = "%02d"% now.day
tagname = "delivery-#{year}#{month}#{day}"
tagdesc = ''
# 选择默认tag还是自定义
puts "\033[33m请选择tag命名:\033[0m\n| 1. 使用默认tag名: \033[37m#{tagname}\033[0m\n| 2. 自定义tag名"
select_tag = $stdin.gets.chomp
if (select_tag == '2') 
    puts "\033[37m请输入自定义tag名字:\033[0m"
    custom_tagname = $stdin.gets.chomp
    tagname = custom_tagname
end

# 选择tag描述
puts "\033[33m请选择tag描述:\033[0m\n| 1. 跳过描述\n| 2. 自定义描述"
select_tag_desc = $stdin.gets.chomp
if (select_tag_desc == '2') 
    puts "\033[37m请输入tag描述:\033[0m"
    tagdesc = $stdin.gets.chomp
end

tag_ret = system("git tag -a #{tagname} -m '#{tagdesc}' && git push origin #{tagname}")
if tag_ret
    puts "\033[32mSuccessfully push tag named: #{tagname}, desc: #{tagdesc}\033[0m"
end