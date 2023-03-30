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
`xcodebuild -target #{target_name} clean`

# pod
pod_file = "Podfile"
if File::exist?(pod_file)
    puts yellow_text("🧠 Find a podfile, next step is exec #{green_text('pod install')}")
    system("pod install")
end


# 构建
puts yellow_text("💼 Start the archive task ...")
archive_path = output_dir + "/#{target_name}"
archive_full_path = archive_path + ".xcarchive"
if has_xcwrokspace then
    `xcodebuild archive -workspace #{proj_full_name} \
    -scheme #{target_name} \
    -configuration Release \
    -archivePath #{archive_path} \
    `
else
    `xcodebuild archive -project #{proj_full_name} \
    -scheme #{target_name} \
    -configuration Release \
    -archivePath #{archive_path} \
    `
end
puts green_text("Archive successfuly in path => #{white_text(archive_path)}")

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
`xcodebuild -exportArchive \
-archivePath #{archive_full_path} \
-exportPath #{output_dir} \
-exportOptionsPlist #{export_options_plist_name}
`
puts yellow_text("👏 App is exported in directory => #{white_text(output_dir)}")

# 删除archive包
puts yellow_text("🚛 Delete the useless archive file #{white_text(archive_full_path)}")
`rm -rf #{archive_full_path}`

puts green_text("💪 Now, Archive work is all finished !")

# 开始上传app
upload("#{output_dir}/#{target_name}.app")
