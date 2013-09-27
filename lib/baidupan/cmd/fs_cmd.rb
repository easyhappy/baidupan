require 'baidupan/cmd/base'
require 'baidupan/fs_cmd'
require 'baidupan'

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


     desc 'list [PATH]', 'list remote files under PATH'
     def list(rpath=nil)
       res = Baidupan::FsCmd.list(rpath)
       res.body[:list].each do |item|
         print_item(item)
       end
     end
  end
end
