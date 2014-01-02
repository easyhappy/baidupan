# coding: utf-8
require "typhoeus"
require 'multi_json'
require 'fiber'

require "baidupan/version"
require "baidupan/config"
require "baidupan/core_ext"

require 'pry'

module Baidupan
  PAN_BASE_URL = "https://pcs.baidu.com/rest/2.0/pcs"

  class Base
    attr_reader :hydra, :body

    class << self
      def get(urls, params={}, opts={}, &block)
        new(urls, :get, params, nil, opts).run!
      end

      def post(urls, params={}, body={}, opts={}, &block)
        new(url, :post, params, body, opts, &block).run!
      end

      def common_params(method, params={})
        params = {access_token: Config.access_token}.merge(params)
        params.merge!(method: method)
      end
    end

    private
    def initialize(urls, method=:get, params={}, body={}, opts={}, &block)
      @options = {
        method: method,
        headers: {"User-Agent"=>"Mozilla/5.0 (X11; Linux x86_64; rv:2.0.1) Gecko/20100101 Firefox/4.0.1"},
        params: params
      }.merge(opts)
      @options.merge!(body: body) if body

      @hydra = Typhoeus::Hydra.new(:max_concurrency => urls.size)
      binding.pry
      urls.each do |url|
        request = Typhoeus::Request.new(url, @options)
        request.on_complete do |response|
          if response.success?
            if response.headers["Content-Disposition"] =~ /attachment;file/ or response.headers["Content-Type"] =~ /image\//
              body = response.body
            else
              body = MultiJson.load(response.body, symbolize_keys: true)
            end
            block.call(response.body) if block_given? 
          end
        end
      end
    end

    def run!
      @hydra.run
    end
  end
end
