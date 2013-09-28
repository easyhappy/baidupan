require 'baidupan'
require 'baidupan/config'

module Baidupan
  
  class FsCmd < Base
    class << self

      def list(rpath, **opts)
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
      	params = common_params(:download, path: "#{Config.app_root}/#{rpath}")
		    get(Config.file_path, params, opts.merge(followlocation: true))
      end
    end
  end
end
