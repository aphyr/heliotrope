module Heliotrope
  $LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))

  class Error < RuntimeError; end
  class Retryable < Error; end

  require 'beefcake'
  require 'heliotrope/util'
  require 'heliotrope/version'
  require 'heliotrope/connection'
  require 'heliotrope/client'
end
