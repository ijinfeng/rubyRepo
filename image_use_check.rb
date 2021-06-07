
<<-Desc
 搜索 *.xcassets 的文件夹
 遍历文件夹下的每张图片
 去项目中查找这张图片是否有被使用到
 判断是否使用的逻辑，通过正则匹配 ‘imageName:’ 掉用
Desc

inputs = ARGV

search_path = ''

if inputs.count > 0 
    search_path = inputs.first
else
    search_path = Dir.pwd
end


class ImageDetector
    def initialize(path)
        @filePath = path
        @imageName = File.basename(path)
    end

    def beginSearch
        puts "imageName=#{@imageName}"
    end
end

detecors = Array.new
# 这些目录不需要搜索
Except_dirs = ['Pods', '.', '..']
# 目标图片文件夹名字后缀
Target_image_dir_extname = '.xcassets'
# 项目中用到的图片名字其实是imageset文件夹的名字
Target_useimage_dir_extname = '.imageset'
#识别的图片后缀类型
Image_extnames = ['.png','.jpg','webp','.jpeg']


def start_search(path)
    Dir.foreach(path) do |entry|
        if Except_dirs.include?(entry)
            next
        end
        full_path = path.to_s + "/" + entry.to_s
        if File.directory? full_path
            if File.extname(full_path) == Target_image_dir_extname
                puts "Find *.xcassets in path=#{full_path}"
                _search_image_inxcassets(full_path)
            else
                start_search(full_path)
            end
        end
    end
end

# 以*.xcassets为开始，遍历图片
def _search_image_inxcassets(path)
    Dir.foreach(path) do |entry|
        full_path = path.to_s + "/" + entry.to_s
        if Except_dirs.include?(entry)
            next
        end
        if File.directory? full_path
            if File.extname(full_path) == Target_useimage_dir_extname
                puts "===#{entry}" 
            else
                _search_image_inxcassets full_path
            end
        end
    end
end


start_search(search_path)