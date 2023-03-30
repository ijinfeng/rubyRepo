#! /usr/bin/ruby

############################################
#                                          #
#  显示Xcode编译项目后不显示Products目录的问题  #
#                                          #
############################################

# 寻找.xcodeproj
proj_name = ""
Dir::glob("*.xcodeproj") do |name|
    proj_name = name
end
if proj_name.empty?
   puts "Cant't find any xcodeproj in this directory." 
   return
end

puts "Successfully find a proj named: #{proj_name}"


target_pbxproj_path = proj_name + "/project.pbxproj"

MAIN_GROUP = "mainGroup"
PRODUCT_REF_GROUP = "productRefGroup"
main_group_value = nil
product_ref_group_value = nil

puts "Find target tag[#{MAIN_GROUP}] in #{target_pbxproj_path}"

# 读取文件内容
content = File.read(target_pbxproj_path)

find_main_group_line = content.gsub(/#{MAIN_GROUP}[\s]*=[\s]*[a-zA-Z0-9]*/).next
if not find_main_group_line.empty? 
    puts "Succefully find one line => #{find_main_group_line}"
    main_group_value = find_main_group_line.gsub(/#{MAIN_GROUP}[\s]*=[\s]*/, '')
    puts "The value of mainGroup is => #{main_group_value}"
end
find_product_ref_group_line = content.gsub(/#{PRODUCT_REF_GROUP}[\s]*=[\s]*[a-zA-Z0-9]*/).next
if not find_product_ref_group_line.empty? 
    puts "Successfully find one line => #{find_product_ref_group_line}"
    product_ref_group_value = find_product_ref_group_line.gsub(/#{PRODUCT_REF_GROUP}[\s]*=[\s]*/, '')
    puts "The value of productRefGroup is => #{product_ref_group_value}"
end

if main_group_value.empty? or product_ref_group_value.empty? 
    puts "The values of mainGroup and productRefGroup cannot both be empty"
    return
end

if main_group_value == product_ref_group_value
    puts "The values of mainGroup and productRefGroup are equal"
    return
end

new_content = content.gsub!(/#{PRODUCT_REF_GROUP}[\s]*=[\s]*[a-zA-Z0-9]*/, "#{PRODUCT_REF_GROUP} = #{main_group_value}")

File.open(target_pbxproj_path, 'w') do |file|
    file.write(new_content)
end

puts "Successfully edit #{PRODUCT_REF_GROUP} value!"
