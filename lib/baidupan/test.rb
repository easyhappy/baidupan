require 'baidupan'
require 'thor'

module Baidupan
  class Test < Thor
    include Thor::Actions

    desc 'test', 'test'
    def test
      puts 'test'
    end
  end
end
