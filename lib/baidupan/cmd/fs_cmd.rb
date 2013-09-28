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
    def upload(lpath, rpath=nil, opts={})
      opts.merge! options.dup
      res = Baidupan::FsCmd.upload(lpath, rpath, opts)
      print_item res.body
    end

    desc 'batch_upload [local dir, remote dir, file_pattern="*"]', <<-Desc
    批量上传文件, 模式需要进行转义, 如下:
    baidupan ./ test_dir \*.gem --show:
    baidupan-0.0.4.gem
    baidupan-0.0.2.gem
    baidupan-0.0.3.gem
    Desc
    option :show, desc: "show files that will be uploaded"
    #option :recursive, desc: "对子目录递归上传", type: :boolean, aliases: [:r]
    def batch_upload(ldir, rdir, file_pattern="*")
      opts = options.dup
      old_ldir = ldir
      if opts.delete[:r]
        ldir = File.join(ldir, "**")
      end
      files = Dir.glob(File.join(ldir, file_pattern)).select{|f| File.file?(f)}
      
      if options[:show]
        files.each{|file| puts file}
        say "total #{files.size} files"
        return
      end

      count = 0
      origin_rdir = rdir
      current_dir = Regexp.new("^#{File.join(old_ldir, '')}")
      
      files.each do |file|
        dirname = File.dirname(file.gsub(current_dir, ''))
        dirname = '' if dirname == '.'

        rdir = File.join(origin_rdir, dirname)
        self.upload(file, rdir)
        count += 1
      end
      say "total upload #{count} files"
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
