# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'baidupan/version'

Gem::Specification.new do |spec|
  spec.name          = "baidupan"
  spec.version       = Baidupan::VERSION
  spec.authors       = ["AndyHu"]
  spec.email         = ["meeasyhappy@gmail.com"]
  spec.description   = %q{利用百度云盘接口， 实现文件备份功能}
  spec.summary       = %q{文件上传和查看等功能}
  spec.homepage      = "http://ml-china.org"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency   "bundler", "~> 1.3"
  spec.add_development_dependency   "rake"
  spec.add_development_dependency   "typhoeus", ~> 0.6.5
  spec.add_runtime_dependency       "thor"
end
