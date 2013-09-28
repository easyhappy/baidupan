require 'baidupan'
require 'baidupan/cmd/base'
require 'baidupan/fs_cmd'

module Baidupan::Cmd

  class FsCmd < Base

    no_tasks do
      def print_item(item)
        new_items = []
        new_items << item[:fs_id]
        new_items << "#{item[:path].sub(Baidupan::Config.app_root + '/', '')}"
        new_items << "#{Time.at(item[:mtime])}"
        print_in_columns new_items
      end
    end


    desc 'list [Remote path]', 'list files under Remote path'
    def list(rpath=nil)
      res = Baidupan::FsCmd.list(rpath)
      res.body[:list].each do |item|
        print_item(item)
      end
     end
    map ls: :list

    desc 'upload [Local path, Remote path]', 'upload a local file /path/to/file --> /apps/appname/[rpath|file]'
    option :ondup, type: :string, desc: <<-Desc, default: :newcopy
overwrite：表示覆盖同名文件；newcopy：表示生成文件副本并进行重命名，命名规则为“文件名_日期.后缀”。
    Desc
    def upload(lpath, rpath=nil)
      res = Baidupan::FsCmd.upload(lpath, rpath, options.dup)
      print_item res.body
    end


    desc 'download file [Remote path, Local path',  'download remote file to local, not support for download dir'
    def download(rpath, lpath=nil)
      lpath = (lpath||rpath).dup
      res = Baidupan::FsCmd.download(rpath, lpath, options.dup)
      
      if File.exists?(lpath)
        extname = File.extname(lpath)
        timestamp_name = "_#{Time.now.strftime(Baidupan::Config.time_format)}_#{rand(10)}#{extname}"

        if extname.empty?
          lpath += timestamp_name
        else
          lpath.gsub!(extname, timestamp_name)
        end
      end

      File.binwrite(lpath, res.body)
      say "download and save at'#{lpath}'..."
    end
  end
end
