require 'baidupan'
require 'baidupan/config'

module Baidupan
  
  class FsCmd < Base
    class << self
      def list(rpath, **opts)
        opts.merge!(common_params(:list, path: "#{Config.app_root}/#{rpath}"))
        get(Config.base_url + "/file", opts)
      end
    end
  end
end
