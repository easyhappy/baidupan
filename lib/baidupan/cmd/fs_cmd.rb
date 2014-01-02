# coding: utf-8

require 'eventmachine'
require 'em-http'
require 'fiber'

require 'baidupan'
require 'baidupan/cmd/base'
require 'baidupan/fs_cmd'
require 'baidupan/cmd/hash'

module Baidupan::Cmd

  class FsCmd < Base
    no_tasks do
      def print_item(item)
        new_items = []
        new_items << item[:fs_id]
        new_items << "#{item[:path].sub(Baidupan::Config.app_root + '/', '')}#{"/" if item[:isdir] == 1}"
        new_items << "#{Time.at(item[:mtime])}"
        print_in_columns new_items
      end
    end

    desc 'list [path1 path2 ...]', 'list files under Remote path'
    def list(*rpaths)
      res = Baidupan::FsCmd.list(rpaths) do |response_body|
        res.body[:list].each do |item|
          print_item(item)
        end
      end
    end
    map ls: :list

    desc 'upload [Local path, Remote path]', 'upload a local file /path/to/file --> /apps/appname/[rpath|file]'
    option :ondup, type: :string, desc: <<-Desc, default: :newcopy
overwrite：表示覆盖同名文件；newcopy：表示生成文件副本并进行重命名，命名规则为“文件名_日期.后缀”。
    Desc
    def upload(lpath, rpath=nil)
      binding.pry
      res = Baidupan::FsCmd.upload(lpath, rpath, options.dup)
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
    option :recursive, desc: "对子目录递归上传", type: :boolean
    def batch_upload(ldir, rdir, file_pattern="*")
      opts = options.dup
      old_ldir = ldir
      
      if opts[:recursive]
        ldir = File.join(ldir, "**")
        opts.delete(:recursive)
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
      
      fibers = []
      files.reverse.each do |file|
        dirname = File.dirname(file.gsub(current_dir, ''))
        dirname = '' if dirname == '.'

        rdir = File.join(origin_rdir, dirname)
        fibers << Fiber.new do
          Baidupan::FsCmd.upload(file, rdir, opts)
        end
        say file
        count += 1
      end
      EM.run do
        fibers.map(&:resume)
      end
      say "total upload #{count} files"
    end

    desc 'download file [Remote path, Local path',  '下载单个文件 download remote file to local, not support for download dir'
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

    desc 'url [remote path]', 'get a stream-file url for using online, e.g. <img src="_streamurl" />'
    def url(rpath)
      say Baidupan::FsCmd.url(rpath)
    end

    desc "thumbnail rpath", "获取指定图片文件的缩略图。"
    option :quality, type: :numeric, desc: "缩略图的质量，默认为“100”，取值范围(0,100]", default: 100
    option :height, type: :numeric, desc: "指定缩略图的高度，取值范围为(0,1600]", default: 200
    option :width, type: :numeric, desc: "指定缩略图的宽度，取值范围为(0,1600]", default: 200
    def thumbnail(rpath)
      opts = options.dup
      say Baidupan::FsCmd.thumbnail(rpath, opts)
    end

    desc 'mkdir rpath', '创建目录 mkdir remote path, e.g. mkdir path/to/newdir'
    def mkdir(rpath)
      print_item Baidupan::FsCmd.mkdir(rpath).body
    end

    desc 'move from_rpath, to_rpath', 'move a remote path/to/from --> path/to/to'
    def mv(from_rpath, to_rpath)
      to_rpath += File.basename(from_rpath) if to_rpath[-1] == '/'                                        
      say "from_rpath不能和to_rpath相同" and return if from_rpath == to_rpath
      
      body = Baidupan::FsCmd.move(from_rpath, to_rpath).body

      say "success to mv file #{body[:extra][:list][0][:from]} ---> #{body[:extra][:list][0][:to]}"
    end

    desc 'copy from_rpath, to_rpath', 'copy a remote path/to/from --> path/to/to'
    def copy(from_rpath, to_rpath)
      to_rpath += File.basename(from_rpath) if to_rpath[-1] == '/'                                        
      say "from_rpath不能和to_rpath相同" and return if from_rpath == to_rpath

      body = Baidupan::FsCmd.copy(from_rpath, to_rpath).body
      say "success to cp file #{body[:extra][:list][0][:from]} ---> #{body[:extra][:list][0][:to]}"    
    end
    map cp: :copy

    desc 'delete rpath', '删除单个文件/目录 delete a remote path'
    option :force, type: :boolean, default: false
    def delete(rpath)
      if options[:force] || yes?("Are you sure to delte #{rpath}?")
        response = Baidupan::FsCmd.delete(rpath).response
        say "success to delete  #{rpath}"if response.success?
      else
        say "Cancel to delete #{rpath}"
      end
    end
    map del: :delete

    desc "quota", '获取当前用户空间配额信息'
    def quota
      body = Baidupan::FsCmd.quota.body
      say "总空间为:#{body[:quota]*1.0/1024**3}G"
      say "已用: #{body[:used]*1.0/1024**3}G"
    end
  end
end
