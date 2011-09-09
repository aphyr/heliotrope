#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib', 'heliotrope'))
require 'heliotrope/queue'
require 'bacon'

Bacon.summary_on_exit 

include Heliotrope

describe Heliotrope::Queue do
  before do
    @c = Heliotrope::Client.new(host: ARGV.first)
    @q = @c.queue 'heliotrope-test'
  end

  should 'put' do
    @q.put 'test'
    @q.take.should == 'test'
  end
end
