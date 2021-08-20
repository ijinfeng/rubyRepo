#! /usr/bin/ruby

cur_path = Dir.pwd

podSpec = ''

# 检查是否存在podSpec文件

Dir.foreach(cur_path) do |entry|
    if entry.match '*.podSpec'
        podSpec = entry
        puts "存在" + color_text(entry, Color.green)
    else
        # 需要创建
    end

end
