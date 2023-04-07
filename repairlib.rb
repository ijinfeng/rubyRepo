#!/usr/bin/ruby

lib_name = "hairenderer"
# 判断当前是否是在framework内部

excute_path = Dir.pwd
excute_in_cur = true
Dir::foreach(excute_path) do |sub|
    if sub == "#{lib_name}.framework"
        excute_in_cur = false
        excute_path += "/#{lib_name}.framework"
    end
end

system("cd #{excute_path} && rm -f #{lib_name} Headers Resources Versions/Current")
real_Versions = excute_path + "/Versions"
real_Versions_A = real_Versions + "/A"
system("ln -s #{real_Versions_A}/#{lib_name} #{excute_path}/#{lib_name}")
system("ln -s #{real_Versions_A}/Headers #{excute_path}/Headers")
system("ln -s #{real_Versions_A}/Resources #{excute_path}/Resources")
system("ln -s #{real_Versions_A} #{real_Versions}/Current")