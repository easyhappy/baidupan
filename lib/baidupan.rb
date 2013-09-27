require "baidupan/version"
require "typhoeus"
require 'multi_json'
require 'pry'

module Baidupan
  PAN_BASE_URL = "https://pcs.baidu.com/rest/2.0/pcs"

  class Base
    attr_reader :body

    def initialize(url, method=:get, params={}, body={}, options={})
      @options = {
        method: method,
        headers: {"User-Agent"=>"Mozilla/5.0 (X11; Linux x86_64; rv:2.0.1) Gecko/20100101 Firefox/4.0.1"},
        params: params
      }
      @options.merge!(body: body) if body
      @options.merge!(options)

      @request = Typhoeus::Request.new(url, @options)
      @request.on_complete do |response|
        if response.success?
          @body = MultiJson.load(response.body, symbolize_keys: true)
        end
      end
    end

    def run!
      @request.run
      self
    end

    class << self
      def get(url, params={}, opts={})
        new(url, :get, params, nil, opts).run!
      end

      def post(url, params={}, body={}, opts={})
      end

      def common_params(method, params={})
        params = {access_token: Baidupan::Config.access_token}.merge(params)
        params.merge!(method: method)
      end
    end
  end
end

