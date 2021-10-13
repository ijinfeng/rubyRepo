#! /usr/bin/ruby

require_relative './log_color'

cur_path = Dir.pwd
has_xcwrokspace = false
xcworkspace_name = ""
xcodeproj_name = ""
open_file_name = ""

Dir::glob('*.xcworkspace') do |name|
    has_xcwrokspace = true
    xcworkspace_name = name
    open_file_name = name
end

if has_xcwrokspace == false 
    Dir.glob('*.xcodeproj') do |name|
        xcodeproj_name = name
        open_file_name = name
    end
end

open_file_path = cur_path + "/" + open_file_name

puts "Start open file: " + color_text(open_file_name, Color.white)
system("open \"#{open_file_path}\"")
