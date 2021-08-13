#! /usr/bin/ruby

require 'xcodeproj'
require_relative './log_color'

# target_dir_path: 目标文件夹路径
# proj_type创建类型：1.playground，2:xcodeproj
def create_proj(target_dir_path=nil, proj_type=1)
    if target_dir_path.nil? == true 
        target_dir_path = Dir.pwd
    end

    puts 'Will create project in path ' + color_text(target_dir_path, Color.green)

    file_name = ''
    if proj_type.to_i == 1 # playground
        file_name = 'MyPlayground.playground'
        if File.exist?(target_dir_path + '/' + file_name)
            puts color_text("A file named #{file_name} already exists", Color.white)
            time = Time.new
            t_append = time.strftime("%Y%m%d%H%M%S")
            file_name = 'MyPlayground' + t_append + '.playground'
        end
        playground_dir = target_dir_path + '/' + file_name
        Dir.mkdir(playground_dir)
        # Contents.swift
        # contents.xcplayground
        # timeline.xctimeline
        File.open(playground_dir + '/Contents.swift', 'w+') do |f|
            f.write('import UIKit')
        end
        File.open(playground_dir + '/contents.xcplayground', 'w+') do |f|
            f.write("<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>
            <playground version='5.0' target-platform='ios' buildActiveScheme='true' executeOnSourceChanges='false' importAppTypes='true'>
                <timeline fileName='timeline.xctimeline'/>
            </playground>")
        end
        File.open(playground_dir + '/timeline.xctimeline', 'w+') do |f|
            f.write("<?xml version=\"1.0\" encoding=\"UTF-8\"?>
            <Timeline
                version = \"3.0\">
                <TimelineItems>
                </TimelineItems>
            </Timeline>")
        end
        puts "Create file #{file_name}"
    elsif proj_type.to_i == 2 # xcodeproj
        file_dir = 'My'
        file_name = "#{file_dir}.xcodeproj"
        if File.exist?(target_dir_path + '/' + file_name)
            time = Time.new
            t_append = time.strftime("%Y%m%d%H%M%S")
            file_dir = 'My' + t_append
            file_name = file_dir + '.xcodeproj'
        end
        my_xcodeproj_path = target_dir_path + '/' + file_name
        project = Xcodeproj::Project.new(my_xcodeproj_path)
        target = project.new_target(:application, file_dir, :ios, nil, nil, :swift)
        # create main.swift
        main_file_dir = target_dir_path + '/' + file_dir
        Dir.mkdir main_file_dir
        main_file_path = main_file_dir + '/main.swift'
        File.open(main_file_path, 'w+') do |f|
            f.write('import Foundation')
            f.write("\n\n")
        end

        puts "Create file main.swift"

        file_ref = project.main_group.new_reference(main_file_path)
        target.add_file_references([file_ref])

        debug_build_setting = target.build_settings 'Debug'
        release_build_setting = target.build_settings 'Release'

        debug_build_setting['SDKROOT'] = 'macosx'
        release_build_setting['SDKROOT'] = 'macosx'

        project.save

        puts "Create file #{file_name}"
    else
    end
    
    
    if not File.exist?(target_dir_path + '/README.md')
        f=File.new(target_dir_path + '/README.md', 'w+')
        puts "Create file README.md"
    end
    
    puts color_text("Start open #{file_name}", Color.green)
    # open "file_path", 处理文件名带有空格的问题
    system("open \"#{target_dir_path + '/' + file_name}\"")
end

