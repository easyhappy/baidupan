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

      def file_path(*files)
        base_file = File.join(self.base_url, 'file')
        files.each do |file|
          base_file = File.join(base_file, file.to_s)
        end

        base_file
      end

      def thumbnail
        File.join(self.base_url, "thumbnail")
      end

      def other_api_path(api)
        File.join(self.base_url, api.to_s)
      end

      def time_format
        "%Y%m%d%H%M%S"
      end

      def join_path(*files)
        files.inject(self.app_root) do |rpath, lpath|
          File.join(rpath, lpath.to_s)
        end
      end

      def rewrite_file(params)
        params.each do |key, value|
          single_instance.config[key] = value
        end
        File.open(CONF_FILE, 'w') {|f| f.write single_instance.config.to_yaml }
      end
    end

    private

    def initialize
      @config = YAML.load_file(CONF_FILE)
    end
  end
end
Baidupan::Config.app_root
