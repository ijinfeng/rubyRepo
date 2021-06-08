#!/usr/bin/ruby
<<-Desc
 搜索 *.xcassets 的文件夹
 遍历文件夹下的每张图片
 去项目中查找这张图片是否有被使用到
 判断是否使用的逻辑，通过正则匹配 ‘imageName:’ 掉用

 OC:          [UIImage imageNamed:@"xxx"]
 Swift:       UIImage(named: "xxx")
Desc

require_relative './log_color'

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

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
Except_dirs = ['Pods', '.', '..', '.git', '.DS_Store', 'xcuserdata', 'xcshareddata', 'fastlane', 'Fastlane']
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
        @match = false
    end

    def image_use?
        @match
    end

    def image_name
        @imageName
    end

    # 在整个项目中查找目标图片是否被使用
    def beginSearch(path=Target_search_path, &block)
        foreachDir(path) do |entry, full_path|
            if File.file? full_path
                file_extname = File.extname(full_path)
                if Search_code_file_extnames.include? (file_extname)
                    # puts "Start search file " + color_text(entry, Color.green) + " in path #{full_path}"
                    _match(full_path) {
                        @match = true
                        if not block.nil?
                            block.call @imageName, full_path
                        end
                        break
                    }
                end
            elsif File.directory? full_path
                # 这里过滤掉一些文件夹
                if File.extname(full_path) == Target_image_dir_extname
                    next
                end
                beginSearch(full_path, &block)
            else
                puts 'Unknow entry ' + color_text(entry, Color.red) + " in path #{full_path}"
            end
        end
    end

    # 目标图片是否在这个路径的文件中被引用
    def _match(path, &block)
        if not File::readable? path
            return
        end
        # 判断是否是 swift 文件
        is_swift = File.extname(path) == '.swift'

        # 匹配判断
        def check_image_oc(str)
            reg = /UIImage[\s]*imageNamed:@"#{@imageName}"/
            reg_png = /UIImage[\s]*imageNamed:@"#{@imageName}\.png"/
            if not (str =~ reg).nil? or not (str =~ reg_png).nil?
                #  puts 'Match success ' + color_text(str, Color.red)
                 return true
            end
            return false
        end

        def check_image_swift(str)
            reg = /UIImage\(named:[\s]*"#{@imageName}"[\s]*\)/
            reg_png = /UIImage\(named:[\s]*"#{@imageName}.png"[\s]*\)/
            if not (str =~ reg).nil? or not (str =~ reg_png).nil?
                #  puts 'Match success ' + color_text(str, Color.red)
                 return true
            end
            return false
        end

        text = File.read(path)
        res = false
        if is_swift == true
            res = check_image_swift text
        else
            res = check_image_oc text
        end
        if res == true
            if not block.nil?
                block.call path
            end
        end
    end
end

def foreachDir(path, &block)
    Dir.foreach(path) do |entry|
        if File.directory?(path) and  Except_dirs.include?(entry)
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
                detector.beginSearch { |image_name, match_file_path|
                    # 当有回调时，表示匹配到了
                    # puts "Match success image named " + color_text(image_name, Color.green) + " in " + color_text(match_file_path, Color.white)
                }
                if not detector.image_use?
                    puts "Image named " + color_text(detector.image_name, Color.red) + " unused！"
                end
            else
                _search_image_inxcassets full_path
            end
        end
    end
end

puts "Begin search..."
start_search(Target_search_path)
puts "Search finished, check appeal images is really unused in project."