#!/usr/bin/env ruby

require 'yaml'
require 'pry'

module Baidupan
  CONF_FILE = File.expand_path("~/.baidupan.yml")

  class Config < Hash
    attr_reader :config

    class << self

      def single_instance
        @_instance ||= new
      end

      def method_missing(method, *args)
        single_instance.config[method.to_sym]
      end
    end

    private

    def initialize
      @config = YAML.load_file(CONF_FILE)
    end
  end
end
Baidupan::Config.app_root
