#!/usr/bin/ruby

require_relative "./upload_app.rb"
require_relative "./color_log.rb"

puts "-------------------------------------------------"
puts "|                 ARCHIVE TASK                  |"
puts "-------------------------------------------------"
puts "🚗 Start exec archive macos script 🚗"
puts "👉 Current exec directory is: #{Dir.pwd}"

cur_path = Dir.pwd
output_dir = "./Build"
# 证书的id
DISTRIBUTION_CODE_SIGN_IDENTITY = "Apple Distribution: Haihuman Technology Co., Ltd. (M69DRNUMV4)"
DEVELOPER_CODE_SIGN_IDENTITY = "Apple Development: le huang (WSJL265X98)"
ARCHIVE_METHOD = "mac-application"
TEAM_ID = "M69DRNUMV4"

has_xcwrokspace = false
open_proj_path = ""
proj_full_name = ""
Dir::glob("*.xcworkspace") do |name|
    has_xcwrokspace = true
    open_proj_path = name
    proj_full_name = File.basename(name)
end

if has_xcwrokspace == false
    Dir::glob("*.xcodeproj") do |name|
        open_proj_path = name
        proj_full_name = File.basename(name)
    end
end

puts yellow_text("Find a valid project named: #{white_text(proj_full_name)}")

# target名字
target_name = File.basename(open_proj_path, ".*")

# 先清理项目
puts yellow_text("First clean the target #{white_text(target_name)} 🧹 ...")
if has_xcwrokspace then
    `xcodebuild clean \
    -workspace #{proj_full_name} \
    -scheme #{target_name} \
    -configuration Release`
else
    `xcodebuild clean \
    -project #{proj_full_name} \
    -scheme #{target_name} \
    -configuration Release`
end

# pod
pod_file = "Podfile"
pod_ret = false
if File::exist?(pod_file)
    puts yellow_text("🧠 Find a podfile, next step is exec #{green_text('pod install')}")
    pod_ret = system("pod install")
end
if pod_ret == false
    return
end

# 构建
puts yellow_text("💼 Start the archive task ...")
archive_path = output_dir + "/#{target_name}"
archive_full_path = archive_path + ".xcarchive"
archive_ret = false
if has_xcwrokspace then
    archive_ret = system("xcodebuild archive -workspace #{proj_full_name} \
    -scheme #{target_name} \
    -configuration Release \
    -archivePath #{archive_path} \
    -arch x86_64 \
    -quiet
    ")
else
    archive_ret = system("xcodebuild archive -project #{proj_full_name} \
    -scheme #{target_name} \
    -configuration Release \
    -archivePath #{archive_path} \
    -arch x86_64 \
    -quiet
    ")
end
if archive_ret == true then
    puts green_text("Successfuly archived in path => #{white_text(archive_path)}")
else
    puts red_text("Archived in failded")
    return
end

# 生成ipa
puts yellow_text("📦 Start generate IPA packet ...")

# 判断是否存在exportPlist文件
export_options_plist_name = "exprotOptionsPlist.plist"
if File::exist?(export_options_plist_name)
    File::delete(export_options_plist_name)
end
puts yellow_text("Start create file #{white_text(export_options_plist_name)}")
`touch #{export_options_plist_name}`
File.open("#{export_options_plist_name}", "w+") do |f|
    f.write("<?xml version=\"1.0\" encoding=\"UTF-8\"?>
    <!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
    <plist version=\"1.0\">
    <dict>
        <key>teamID</key>
        <string>#{TEAM_ID}</string>
        <key>method</key>
        <string>#{ARCHIVE_METHOD}</string>
        <key>compileBitcode</key>
        <false/>
    </dict>
    </plist>")
end

# 开始导出APP
puts yellow_text("Start export app ⛓️ ...")
export_ret = false
export_ret = system("xcodebuild -exportArchive \
-archivePath #{archive_full_path} \
-exportPath #{output_dir} \
-exportOptionsPlist #{export_options_plist_name}
")
if export_ret == true then
    puts yellow_text("👏 App had exported in directory => #{white_text(output_dir)}")
else
    puts red_text("Exported in failded")
    return
end

# 删除archive包
puts yellow_text("🚛 Delete the useless archive file #{white_text(archive_full_path)}")
`rm -rf #{archive_full_path}`

puts green_text("💪 Now, Archive work is all finished!")

# 开始上传app
upload("#{output_dir}/#{target_name}.app")