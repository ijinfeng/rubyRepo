#!/usr/bin/ruby

require_relative "./color_log.rb"
require 'net/http'
require 'uri'
require 'json'

# zip下载地址
GIT_DOWNLOAD_URL = "http://gitlab.haihuman.com/feng.jin/macos-archive/-/archive/main/macos-archive-main.zip"
# 上传到git的地址
GIT_REMOTE_SOURCE = "http://gitlab.haihuman.com/feng.jin/macos-archive.git"

# 发送钉钉消息
# https://oapi.dingtalk.com/robot/send?access_token=58c9c3f3704d4353963f129871e30fb3884acc67e722374fdc70b8cf05cfaff0
def dingTalk
    # 获取最近一次提交描述
    puts `pwd`
    commit_msg = `git log --pretty=format:\"%s\" --graph -1`
    # 获取最近一次提交作者
    commit_author_msg = `git log --pretty=\"%an %ae\" -1`
    # 获取当前分支名字
    branch_name = `git symbolic-ref --short -q HEAD`
    dingTalk_url = "https://oapi.dingtalk.com/robot/send?access_token=58c9c3f3704d4353963f129871e30fb3884acc67e722374fdc70b8cf05cfaff0"
  
  markdown = 
    {
      msgtype: "markdown", 
      markdown: {
          title: "SDKSample-OSX有新版本了🎉", 
          text: "### 💻 SDKSample-OSX 构建包 内测版\n
          [点击下载压缩包](#{GIT_DOWNLOAD_URL})
          ---
          👉 分支名字: #{branch_name}\n
          👉 提交记录: #{commit_msg}\n
          👉 作者: #{commit_author_msg}\n
          ---
          ### 安装说明
          👉 遇到【无法打开“SDKSample-OSX”, 因为它来自身份不明的开发者。】请打开系统偏好设置 - 安全性与隐私 - 在允许从以下位置下载的APP中找到按钮【仍要打开】`\n
          👉 遇到弹出的提示是【从互联网下载的APP。您确定要打开它吗?】请点击打开。
          ",
      }
   }
    uri = URI.parse(dingTalk_url)
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true
    request = Net::HTTP::Post.new(uri.request_uri)
    request.add_field('Content-Type', 'application/json')
    request.body = markdown.to_json
    response = https.request(request)
    puts "------------------------------"
    puts "Response #{response.code} #{response.message}: #{response.body}"
    if response.code == "200" then
      puts "✅ 已发送钉消息 ✅"
    else
      puts "❎ 钉消息发送失败 ❎"
    end
  end


# 上传App接口
def upload(path)
    puts "-------------------------------------------------"
    puts "|                 UPLOAD TASK                    |"
    puts "-------------------------------------------------"
    puts "👮‍♀️ First check the upload app in path => #{white_text(path)}"
    # 先查找下APP是否存在
    if File::exist?(path) == false
        puts red_text("No app can be found to upload")
        return
    end
    puts green_text("🔍 Successfully find a APP")

    dir_name = File::dirname(path)

   # 检查下当前目录下是否存在git
   if File::exist?("#{dir_name}/.git") == false
        puts yellow_text("🔧 Initialize git in dir => #{white_text(dir_name)}")
        `git init #{dir_name}`
        `cd #{dir_name} && git remote add origin #{GIT_REMOTE_SOURCE}`
   end

   # 开始上传
   `cd #{dir_name} && git add .`
   `cd #{dir_name} && git commit -m "Upload APP"`
   `cd #{dir_name} && git push origin main -u -f`

   puts green_text("Anything has be upload to git => #{GIT_REMOTE_SOURCE}")

   dingTalk
end

dingTalk