# coding: utf-8
require "typhoeus"
require 'multi_json'

require "baidupan/version"
require "baidupan/config"
require "baidupan/core_ext"

require 'pry'

module Baidupan
  class Base
    attr_reader :hydra, :body
    @@single_instance = nil

    class << self

      def get(url, opts, params={}, &block)
        opts = [opts] unless opts.kind_of?(Array)

        single_instance = Baidupan::Base.new opts.size  
        opts.each do |opt|
          single_instance.queue_request(url, :get, opt, nil, params, &block)
        end

        single_instance.run!
      end

      def post(url, opts={}, body={}, params={}, &block)
        @@single_instance ||= Baidupan::Base.new
        @@single_instance.queue_request(url, :post, opts, body, params, &block)
      end

      def common_params(method, params={})
        params = {access_token: Config.access_token}.merge(params)
        params.merge!(method: method)
      end
    end

    def queue_request(url, method=:get, params={}, body={}, opts={}, &block)
      @options = {
        method: method,
        headers: {"User-Agent"=>"Mozilla/5.0 (X11; Linux x86_64; rv:2.0.1) Gecko/20100101 Firefox/4.0.1"},
        params: params
      }.merge(opts)
      @options.merge!(body: body) if body

      request = Typhoeus::Request.new(url, @options)
      request.on_complete do |response|
        if response.success?
          body = nil
          if response.headers["Content-Disposition"] =~ /attachment;file/ or response.headers["Content-Type"] =~ /image\//
            body = response.body
          else
            body = MultiJson.load(response.body, symbolize_keys: true)
          end
          block.call(body, response.request.options[:params][:path]) if block_given?
        end
      end
      
      @hydra.queue request
    end

    def run!
      @hydra.run
    end

    private
    def initialize(max_concurrency=200)
      @hydra = Typhoeus::Hydra.new(:max_concurrency => max_concurrency)
    end
  end
end
