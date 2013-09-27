require "baidupan/version"
require "typhoeus"

module Baidupan
  PAN_BASE_URL = "https://pcs.baidu.com/rest/2.0/pcs"

  class Base
    def initialize(url, method=:get, params={}, body={}, options={})
      @options = {
        method: method,
        header: {"User-Agent"=>"Mozilla/5.0 (X11; Linux x86_64; rv:2.0.1) Gecko/20100101 Firefox/4.0.1"},
        params: params
      }
      @options.merge!(body: body) if body
      @options.merge!(options)

      @request = Typhoeus::Request.new(url, @options)
      @request.on_complete do |response|
        if response.success?
          @body = response.body
        end
        puts response.code
      end

      #思考这里的self有什么含义
    end

    def run!
      @request.run
    end

    class << self
      def get(url, params={}, opts={})
        params.merge!(method_params)
        new(url, :get, params, nil, opts).run!
      end

      def post(url, params={}, body={}, opts={})
      end

      def method_params(params={})
        params.merge(access_token: '3.c6fd22305de68bd2f2c6ecf43b5333b5.2592000.1382754307.2435569571-1463515')
        params.merge(path: '/apps/andy_backup', method: :list)
      end
    end
  end
end

Baidupan::Base.get(Baidupan::PAN_BASE_URL + '/file')
