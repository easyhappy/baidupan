#!/usr/bin/env ruby

require 'baidupan'
require 'thor'

module Baidupan::Cmd
  class Base < Thor
    include Thor::Actions
  end
end
