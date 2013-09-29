require 'baidupan'
require 'baidupan/config'

module Baidupan
  
  class FsCmd < Base
    class << self

      def list(rpath, opts={})
        opts.merge!(common_params(:list, path: "#{Config.app_root}/#{rpath}"))
        get(Config.file_path, opts)
      end

      def upload(lpath, rpath, opts={})
      	params = common_params(:upload, path: "#{Config.join_path(rpath, File.basename(lpath))}").merge(ondup: :newcopy)
      	params[:ondup] = opts.delete(:ondup) if opts[:ondup]
        
        body = {:file => File.open(lpath)}
        opts[:noprogress] ||= true

      	post(Config.file_path, params, body, opts)
      end

      def download(rpath, lpath, opts={})
      	params = common_params(:download, path: "#{Config.join(rpath)}")
		    get(Config.file_path, params, opts.merge(followlocation: true))
      end

      def url(rpath)
        params = common_params(:download, path: "#{Config.join_path(rpath)}")
        "#{Config.file_path}?#{params.to_query_str}"
      end

      def thumbnail(rpath, opts={})
        params = common_params(:generate, path: "#{Config.join_path(rpath)}").merge(opts)
        "#{Config.thumbnail}?" + params.to_query_str
      end

      def mkdir(rpath)
        post(Config.file_path, common_params(:mkdir, path: "#{Config.join_path(rpath)}"))
      end
    end
  end
end
