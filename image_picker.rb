#!/usr/bin/ruby

# 当没有输入路径时，默认为当前路径下
# 当传入路径时，搜索指定路径下的文件

# 重复图片
# 项目中未使用的图片

inputs = ARGV

search_path = ''

if inputs.count > 0 
    search_path = inputs.first
else
    search_path = Dir.pwd
end

# puts "Target search path is: #{search_path}"

class ImagePicker
    def initialize(search_path)
        # 需要剔除的目录
        @except = ['.', '..']
        # 需要搜索的文件后缀
        @file_ext = ['.png', '.jpg', '.jpeg', '.webp']
        # 需要忽略的文件夹名字
        @ignore_dirs = []
        # 文件：文件路径
        @file_map = Hash.new
        # 存重复的文件：文件路径
        @repeat_file_map = Hash.new
        @search_path = search_path
    end
    def except
        @except
    end
    def file_ext
        @file_ext
    end
    def repeat_file_map
        @repeat_file_map
    end
    def file_map
        @file_map
    end
    def add_repeat_file(file, path)
        if not file.empty? 
            @repeat_file_map[file] = path
        end
    end
    def add_file(file, path) 
        if @file_map.has_key? file
            add_repeat_file file, path
            return false
        else
            @file_map[file] = path
            return true
        end
    end
    def search_path
        @search_path
    end
end

# 检查图片是否有在项目中用到
def _search_image_use(image_name, path)
    Dir.foreach path do |entry|

    end
end

def _search_file(path, image_picker = ImagePicker.new)
    # puts "Current search path is: #{path}"
    Dir.foreach path do |entry|
        # puts "  Find entry: #{entry}"
        if image_picker.except.include? entry
            # puts "  Skip special entry: #{entry}"
            next
        end
        entry_path = path.to_s + "/" + entry.to_s
        if File.file? entry_path
            # puts "      The entry|#{entry}| is a file"
            extname = File.extname entry
            # puts "File extname is: #{extname}"
            if image_picker.file_ext.include? extname
                output = "Find image -> #{entry}"
                whitespace_count = 50 - output.length
                if whitespace_count <= 0 
                    whitespace_count = 1
                end
                whitespace_str = ' ' * whitespace_count
                puts "#{output}#{whitespace_str}-> #{entry_path}"
                added = image_picker.add_file entry, entry_path
                # 文件添加成功
                if added 
                    # 去搜索项目中是否用到
                    _search_image_use entry, image_picker.search_path
                end
            end
        elsif File.directory? entry_path
            # puts "      The entry|#{entry}| is a directory"
            if not Dir.empty? entry_path 
                # puts "Enter directory: #{entry_path}"
                _search_file entry_path,image_picker
            end
        else
            puts "      Unknow entry, check the entry of path: #{pentry_path}"
        end
    end
end

image_picker = ImagePicker.new(search_path)

# start search
_search_file image_picker.search_path, image_picker

# 打印重复引入的文件
image_picker.repeat_file_map.keys.each do |entry|
    puts "File repeatition -> #{entry}"
end

