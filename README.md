# Baidupan

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'baidupan'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install baidupan



## Usage
如何使用该gem：

  * 创建百度应用 http://developer.baidu.com/wiki/index.php?title=%E5%B8%AE%E5%8A%A9%E6%96%87%E6%A1%A3%E9%A6%96%E9%A1%B5

  * baidupan setup 应用名字 api_key, secret_key

  * baidupan config 按照提示 进行授权
  
基本命令:

  * baidupan setup 添加文件信息

  * baidupan config 进行授权

  * baidupan list or ls 显示app应用的文件列表

  * baidupan upload 文件

  * 更多命令 请运行baidupan 查看即可
  
Todo：
  * 移动文件的位置

  * 删除文件

  * 对文件重命名

已经实现:
  * 通过配置连接百度盘
  
  * 能够上传、下载以及显示文件



## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
