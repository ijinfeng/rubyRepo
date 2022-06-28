#! /usr/bin/ruby

class Color
    def self.natural
        0
    end
    def self.black
        30
    end
    def self.red
        31
    end
    def self.green
        32
    end
    def self.yellow
        33
    end
    def self.blue
        34
    end
    def self.magenta
        35
    end
    def self.cyan
        36
    end
    def self.white
        37
    end
end

def color_text(text, color = Color.natural)
    if color == 0
        return text
    end
    return "\033[#{color}m#{text}\033[0m"
end

def die_log(text)
    puts color_text(text, Color.red)
end

# 拉取最新代码
# if system('git pull --rebase origin') == false
#     system('git rebase --abort')
#     puts color_text("There is a conflict, please handle it and retry", Color.red)
#     return
# end


cur_path = Dir.pwd
push_path = cur_path
relate_dir_path = ''
push_podspec_name = ''
user_custom_version = true
verify_podspec_format = true
pod_repo_name = 'trunk'
pod_repo_source =
is_static_lib = false
sources = ''

# 检查是否存在 SpecPushFile 文件，如果不存在，那么创建
if not File::exist?(cur_path + '/PodPushFile')
    system('touch PodPushFile')
    File.open(cur_path + '/PodPushFile', 'w+') do |f|
        f.write("#写入*.podspec所在的相对目录，不写默认会在脚本执行的目录下查找
PUSH_DIR_PATH=
#用户还可以指定要推送的podspec文件的名字，这个存在多个podspec的时候会用到
PUSH_PODSPEC_NAME=
#是否允许用户自定义版本号，不填或填true将允许用户设置自定义的版本号，而不是自增版本号
USER_CUSTOM_VERSION=true
#默认开启验证，可以跳过验证阶段
VERIFY_PODSPEC_FORMAT=true
#pod repo的名字，如果是私有库就填私有库的名字
POD_REPO_NAME=trunk
#pod repo的源地址
POD_REPO_SOURCE=https://github.com/CocoaPods/Specs
#如果这个库是静态库，那么需要设置为true
POD_IS_STATIC_LIBRARY=false
#校验podspec文件时如果依赖私有库，会到远程podspec库查找相关依赖，默认只会到官方specs库校验，此时需要指定远程specs库去校验。
SEARCH_SOURCES=")
    end
    puts color_text('Create PodPushFile', Color.green)
    puts color_text("First you should modify 'PodPushFile' file and run the script again", Color.white)
    system('open PodPushFile')
    return
end

puts color_text('Parse PodPushFile...', Color.white)
File.open(cur_path + '/PodPushFile') do |f|
    f.each_line do |line|
        key_value = line.split('=')
        key = key_value.first.to_s.gsub("\n", '').gsub(' ','').gsub("\t",'')
        value =
        if key_value.count > 1
            value = key_value.last.to_s.gsub("\n", '').gsub(' ','').gsub("\t",'')
        end
        # puts "key=#{key},value=#{value}"
        if key.to_s == 'PUSH_DIR_PATH' and not value.nil?
            relate_dir_path = value
            push_path = cur_path + '/' + relate_dir_path
        elsif key.to_s == 'PUSH_PODSPEC_NAME' and not value.nil?
            push_podspec_name = value.to_s
        elsif key.to_s == 'USER_CUSTOM_VERSION' and not value.nil?
            user_custom_version = value == 'true'
        elsif key.to_s == 'VERIFY_PODSPEC_FORMAT' and not value.nil?
            verify_podspec_format = value == 'true'
        elsif key.to_s == 'POD_REPO_NAME' and not value.nil?
            pod_repo_name = value.to_s
        elsif key.to_s == 'POD_REPO_SOURCE' and not value.nil?
            pod_repo_source = value
        elsif key.to_s == 'POD_IS_STATIC_LIBRARY' and not value.nil?
            is_static_lib = value == 'true'
        elsif key.to_s == 'SEARCH_SOURCES' and not value.nil?
            sources = value.to_s
        end
    end
end

# puts "Push path is: #{push_path}, relate dir path is: #{relate_dir_path}"

# 搜索podspec路径
podspec_path = ''
find_podspec_reg = relate_dir_path.length == 0 ? '' : (relate_dir_path + '/')
if push_podspec_name.length > 0
    # 用户指定要推送某个podspec
    if push_podspec_name.include?('.podspec')
        find_podspec_reg += push_podspec_name
    else
        find_podspec_reg += (push_podspec_name + '.podspec')
    end
else
    find_podspec_reg += '*.podspec'
end

#puts "Find podspec reg = #{find_podspec_reg}"
# 有可能存在多个 podspec，当用户没有指定时，需要给用户自主选择
find_podspec_count = 0
podspecs = Array.new
Dir::glob(find_podspec_reg) do |f|
    find_podspec_count += 1
    podspecs << f
end

if podspecs.count > 1
    inputTag = true
    serial = 0
    puts color_text("Find #{podspecs.count} podspec files, please enter the serial number selection:",Color.white)
    while inputTag
        for i in 0...podspecs.count do
            puts "#{i+1}. #{podspecs[i]}"
        end
        serial = gets.chomp
        inputTag = (serial.to_i > podspecs.count || serial.to_i <= 0)
        if inputTag
            puts "Input serial = #{serial}, it's invalid and you need to input 1~#{podspecs.count}:"
        end
    end
    podspec_path = podspecs[serial.to_i-1]
elsif podspecs.count == 1
    podspec_path = podspecs[0]
else
    puts color_text("Can't find any podspec file", Color.red)
    return
end

if not File::exist?(podspec_path)
    die_log("Can't find any podspec file in path: #{podspec_path}, please modify PodPushFile' PUSH_DIR_PATH(key)")
    return
else
    puts "Ready to deal with podspec named " + color_text("#{podspec_path}", Color.white)
end

# 在当前podspec目录下新建一个临时 need_delete_temp.podspec 文件
podspec_dir = File.dirname podspec_path
podspec_absolute_path = cur_path + '/' + podspec_path
temp_podspec_path = podspec_dir + '/need_delete_temp.podspec'
temp_podspec_absolute_path = cur_path + '/' + temp_podspec_path

cur_version = ''
# 读取当前podspec文件的版本
File.open(podspec_absolute_path, 'r+') do |f|
    f.each_line do |line|
        # 查找.version
        version_desc = /.*\.version[\s]*=.*/.match line
        if not version_desc.nil?
            cur_version = version_desc.to_s.split('=').last.to_s.gsub("'", '')
            cur_version = cur_version.gsub(' ', '')
            break
        end
    end
end

puts color_text("Current version = ", Color.white) + color_text("#{cur_version}", Color.green)

# 允许自定义版本号
if user_custom_version == true
    puts color_text "Please input pod lib's new version, if there is no input or less than or equal old version, it will be incremented:", Color.white
    input_version = gets.chomp

    # 判断输入的version是否>当前的版本号
    input_v_s = input_version.to_s.split('.')
    cur_v_s = cur_version.split('.')
    # 比较的位置，从最左边开始
    v_index = 0
    # 输入的version是否有效
    input_valid = false
    while v_index < cur_v_s.count && v_index < input_v_s.count do
        if input_v_s[v_index].to_i > cur_v_s[v_index].to_i
            # 说明用户输入的version比当前的大
            input_valid = true
            break
        elsif input_v_s[v_index].to_i == cur_v_s[v_index].to_i
            v_index += 1
        else
            break
        end
    end

    if input_valid == false
        puts color_text "Input invalid version = #{input_version}，will auto +1 in last component", Color.natural
    end
end

if not File.exist? temp_podspec_absolute_path
    # system("cp -f #{podspec_path} #{temp_podspec_path}")
    system("touch #{temp_podspec_path}")
end

new_version = ''
git_source = ''
File.open(temp_podspec_absolute_path, 'r+') do |t|
    File.open(podspec_absolute_path) do |f|
        f.each_line do |line|
            # # 查找.version
            # s.version      = "0.0.2"
            # 需要注意的是，版本号可以是''，也可以是""
            write_line = line
            version_desc = /.*\.version[\s]*=.*/.match line
            if not version_desc.nil?
                version_coms = version_desc.to_s.split('=')
                if input_valid == true and user_custom_version == true
                    new_version = input_version.to_s
                else
                    version_num = version_coms.last.to_s.gsub("'",'').gsub("\"",'').gsub(' ','')
                    v_s = version_num.split('.')
                    # 处理版本号 0.0.1
                    for i in 0...v_s.count do
                        if i == v_s.count - 1
                            new_version += (v_s[i].to_i + 1).to_s
                        else
                            new_version += (v_s[i].to_s + '.')
                        end
                    end
                end
                puts color_text("New version = ",Color.white) + color_text("#{new_version}", Color.green)
                write_line = version_coms.first.to_s + '=' + " '#{new_version}'" + "\n"
            end
            source_desc = /.*\.source[\s]*=.*/.match line
            if not source_desc.nil?
                source_desc = /:git.*,/.match source_desc.to_s
                source_desc = /'.*'/.match source_desc.to_s
                git_source = source_desc.to_s.gsub("'",'')
                puts "git source is #{git_source}"
            end
            t.write write_line
        end
    end
end

puts color_text("Update version from ",Color.white) + color_text("#{cur_version}",Color.green) + color_text(" to ",Color.white) + color_text("#{new_version}", Color.green)

# 将新数据反写回到原始podspec中
system("cp -f #{temp_podspec_path} #{podspec_path}")
system("rm -f #{temp_podspec_path}")


# 如果本地没有这个repo，那么添加
if system("pod repo | grep #{pod_repo_name}") == false
    puts color_text("Add pod repo named '#{pod_repo_name}' with source: #{pod_repo_source}", Color.white)
    system("pod repo add #{pod_repo_name} #{pod_repo_source}")
end

# 提交代码到远程仓库
puts color_text('Start upload code to remote', Color.white)
system("git commit -am 'update version to #{new_version}'")
if system('git push origin') == false
    die_log('[!] git push code error')
end
system("git tag #{new_version}")
if system('git push origin --tags') == false
    die_log('[!] git push tags error')
    return
end

# 验证podspec格式是否正确
if verify_podspec_format == true
    __sources = sources.nil? ? '' : "--sources=#{sources}"
    puts color_text("Start verify podspec '#{podspec_path}'...", Color.white)
    if system("pod lib lint #{podspec_path} #{__sources} --allow-warnings") == false
        die_log("[!] pod spec' format invalid")
        return
    end
end

# 提交pod spec到spec仓库
puts color_text("Start push pod '#{podspec_path}' to remote repo '#{pod_repo_name}'", Color.white)
if pod_repo_name == 'trunk'
    if (is_static_lib == true ? system("pod trunk push #{podspec_path} --allow-warnings --use-libraries") : system("pod trunk push #{podspec_path} --allow-warnings")) == false
        puts "If not timeout, you need to check your 'trunk' account like: 'pod trunk me', and register code is 'pod trunk register <your email> <your name>'"
        return
    end
else
    if (is_static_lib == true ? system("pod repo push #{pod_repo_name} #{podspec_path} --allow-warnings --use-libraries") : system("pod repo push #{pod_repo_name} #{podspec_path} --allow-warnings"))  == false
        return
    end
end
puts color_text("Update success ☕️! Current version = #{new_version}", Color.green)


