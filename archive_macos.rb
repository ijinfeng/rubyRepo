#!/usr/bin/ruby

puts "Start exec archive macos script 🚗"
puts "Current exec directory is: #{Dir.pwd}"

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

puts "Find a valid project named: #{proj_full_name}"

target_name = File.basename(open_proj_path, ".*")

# 先清理项目
puts "First clean the target #{target_name} 🧹 ..."
`xcodebuild -target #{target_name} clean`

# 构建
puts "Start the archive task 💼 ..."
archive_path = output_dir + "/#{target_name}"
archive_full_path = archive_path + ".xcarchive"
if has_xcwrokspace then
    `xcodebuild archive -wrokspace #{proj_full_name} \
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
puts "Archive successfuly in path => #{archive_path}"

# 生成ipa
puts "Start generate IPA packet 📦 ..."

# 判断是否存在exportPlist文件
export_options_plist_name = "exprotOptionsPlist.plist"
if File::exist?(export_options_plist_name)
    File::delete(export_options_plist_name)
end
puts "Start create a #{export_options_plist_name} file in #{cur_path}"
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

# 开始导出IPA
puts "Start export ipa ⛓️ ..."
`xcodebuild -exportArchive \
-archivePath #{archive_full_path} \
-exportPath #{output_dir} \
-exportOptionsPlist #{export_options_plist_name}
`
puts "IPA is exported in directory => #{output_dir}"

# 删除archive包
puts "Delete the useless archive file 🚛"
`rm -rf #{archive_full_path}`

puts "💪 Now, Archive work is all finished ! ☕️"