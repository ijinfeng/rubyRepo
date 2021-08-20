#! /usr/bin/ruby

# pod repo create

# 在下列目录下存放着podspec的各种仓库，如github上的trunk，或者是私有的 ’myrepo‘ 
# ~/.cocoapods/repos/

inputs = ARGV

proj_path = inputs.count > 0 ? inputs.first : Dir.pwd

puts 'Please input podSpec\'s name:'
spec_name = gets.chomp

system("pod spec create #{spec_name}")
puts "Create a podSpec named #{spec_name}.podspec"

system("open \"#{spec_name}.podspec\"")



