require 'baidupan'
require 'baidupan/config'

module Baidupan
  
  class FsCmd < Base
    class << self

      def list(rpath, **opts)
        opts.merge!(common_params(:list, path: "#{Config.app_root}/#{rpath}"))
        get(Config.base_url + "/file", opts)
      end

      def upload(lpath, rpath, **opts)
      	params = common_params(:upload, path: "#{Config.app_root}/#{rpath}/#{lpath}").merge(ondup: :newcopy)
        body = {:file => File.open(lpath)}
        opts[:noprogress] ||= true

      	post(Config.base_url + "/file", params, body, opts)
      end
    end
  end
end
