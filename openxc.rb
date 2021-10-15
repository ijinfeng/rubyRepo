#! /usr/bin/ruby

require_relative './log_color'

append = ARGV.first

cur_path = Dir.pwd
if not append.nil? and File.directory? append
    cur_path = append
end


has_xcwrokspace = false
open_file_name = ""
open_file_path = ""

Dir::glob("#{cur_path}/*.xcworkspace") do |name|
    has_xcwrokspace = true
    open_file_path = name
    open_file_name = File.basename(name)
end

if has_xcwrokspace == false 
    Dir.glob("#{cur_path}/*.xcodeproj") do |name|
        open_file_path = name
        open_file_name = File.basename(name)
    end
end

puts "target file path is: #{open_file_path}"

puts "Start open file: " + color_text(open_file_name, Color.white)
system("open \"#{open_file_path}\"")
