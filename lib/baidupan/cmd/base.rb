#!/usr/bin/env ruby

require 'baidupan'
require 'thor'

module Baidupan::Cmd
  class Base < Thor
    include Thor::Actions

    desc 'setup [app_name, api_key, secret_key]', "setup your setting when you first use this gem; if you don't have baidu app, please create one: at http://developer.baidu.com/wiki/index.php?title=%E5%B8%AE%E5%8A%A9%E6%96%87%E6%A1%A3%E9%A6%96%E9%A1%B5"
    def setup(app_name, api_key, secret_key)
      require 'erb'
      content = (ERB.new <<-EOF).result(binding)
:app_name: <%=app_name||'<_app_name>'%>
:app_root: /apps/<%=app_name||'<_app_name_or_you_set_in_baidu>'%>
:api_key: <%=api_key||'<_api_key>'%>
:secret_key: <%=secret_key||'<_secret_key>'%>
:base_url:  https://pcs.baidu.com/rest/2.0/pcs
      EOF

      config_path = Baidupan::CONF_FILE
      File.write(config_path, content)
      say "Has wrote #{config_path} for app settings."
    end

    desc 'config', 'config your access token'
    def config
      url = "https://openapi.baidu.com/oauth/2.0/authorize?response_type=token&client_id=#{Baidupan::Config.api_key}&redirect_uri=oob&scope=netdisk"
      say "请在浏览器中完成授权操作并获取最终成功url！\n将下面的链接粘入浏览器获取access_token"
      say '*'*60
      say url
      say '*'*60
      
      say "将浏览器的url输入到这里：" 
      atoken = STDIN.gets.chomp

      atoken =~ /access_token=([^&]*)/
      atoken = $1 if $1

      raise "Invalid token: #{atoken}!" if atoken !~ /^[\da-f\.\-]*$/
      File.open(Baidupan::CONF_FILE, "a"){|f| f.puts ":access_token: #{atoken}" }

      say '-'*60
      say "Have append access token into file: #{Baidupan::CONF_FILE}"
    end


    desc 'show_config', '显示config相关信息'
    def show_config
      puts "Using config file: #{Baidupan::CONF_FILE}"
      puts "With content:"
      puts File.read(Baidupan::CONF_FILE)
    end
  end
end
