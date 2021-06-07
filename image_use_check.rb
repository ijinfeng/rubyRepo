
<<-Desc
 搜索 *.xcassets 的文件夹
 遍历文件夹下的每张图片
 去项目中查找这张图片是否有被使用到
 判断是否使用的逻辑，通过正则匹配 ‘imageName:’ 掉用

 OC:          [UIImage imageNamed:@"xxx"]
 Swift:       UIImage(named: "xxx")
Desc

require './log_color'

inputs = ARGV

# 目标搜索路径
search_path = ''

if inputs.count > 0 
    search_path = inputs.first
else
    search_path = Dir.pwd
end

# 目标搜索路径
Target_search_path = search_path
# 这些目录不需要搜索
Except_dirs = ['Pods', '.', '..']
# 目标图片文件夹名字后缀
Target_image_dir_extname = '.xcassets'
# 项目中用到的图片名字其实是imageset文件夹的名字
Target_useimage_dir_extname = '.imageset'
# 识别的图片后缀类型
Image_extnames = ['.png','.jpg','webp','.jpeg']
# 搜索的文件后缀
Search_code_file_extnames = ['.h', '.m', '.mm', '.swift']



class ImageDetector
    def initialize(path)
        @filePath = path
        @imageName = File.basename(path, Target_useimage_dir_extname)
        puts "Find image named " + color_text(@imageName, Color.white)
    end

    # 在整个项目中查找目标图片是否被使用
    def beginSearch(path=Target_search_path)
        foreachDir(path) do |entry, full_path|
            if File.file? full_path
                file_extname = File.extname(full_path)
                if Search_code_file_extnames.include? (file_extname)
                    puts "Start search file " + color_text(entry, Color.green) + " in path #{full_path}"
                    _match full_path
                end
            elsif File.directory? full_path
                beginSearch(full_path)
            else
                puts 'Unknow entry ' + color_text(entry, Color.red) + " in path #{full_path}"
            end
        end
    end

    # 目标图片是否在这个路径的文件中被引用
    def _match(path)
        if not File::readable? path
            return
        end
        # 判断是否是 swift 文件
        is_swift = File.extname(path) == '.swift'


        f = File.open(path, 'r')   
        f.each_line do |line|
            # puts line





        end
        f.close
    end
end

def foreachDir(path, &block)
    Dir.foreach(path) do |entry|
        if Except_dirs.include?(entry)
            next
        end
        if not block.nil? 
            full_path = path.to_s + "/" + entry.to_s
            block.call entry, full_path
        end
    end
end

def start_search(path)
    foreachDir(path) do |entry, full_path|
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
    foreachDir(path) do |entry, full_path|
        if File.directory? full_path
            if File.extname(full_path) == Target_useimage_dir_extname
                # 找到图片，查看这个图片是否在项目中有被使用
                detector = ImageDetector.new(full_path)
                detector.beginSearch
            else
                _search_image_inxcassets full_path
            end
        end
    end
end


start_search(Target_search_path)