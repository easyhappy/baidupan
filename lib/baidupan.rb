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
    attr_reader :body, :response
    attr_reader :hydra

    def initialize(urls, method=:get, params={}, body={}, opts={})
      @options = {
        method: method,
        headers: {"User-Agent"=>"Mozilla/5.0 (X11; Linux x86_64; rv:2.0.1) Gecko/20100101 Firefox/4.0.1"},
        params: params
      }
      @options.merge!(body: body) if body
      @options.merge!(opts)
      @hydra = Typhoeus::Hydra.new(:max_concurrency => urls.size)
      urls.each do |url|
        @request = Typhoeus::Request.new(url, @options)
        @request.on_complete do |response|
          @response = response
          puts @request.options[:params][:path]
          if response.success?
            if response.headers["Content-Disposition"] =~ /attachment;file/ or response.headers["Content-Type"] =~ /image\//
              @body = response.body
            else
              @body = MultiJson.load(response.body, symbolize_keys: true)
            end
          end
        end
      end
    end

    def run!
      @hydra.run
      self
    end

    class << self
      def get(url, params={}, opts={})
        new(url, :get, params, nil, opts).run!
        Fiber.yield
      end

      def post(url, params={}, body={}, opts={})
        new(url, :post, params, body, opts).run!
        Fiber.yield
      end

      def common_params(method, params={})
        params = {access_token: Config.access_token}.merge(params)
        params.merge!(method: method)
      end
    end
  end
end
