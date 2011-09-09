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
    x = rand.to_s
    @q.put x
    @q.take.should == x
  end

  should 'take' do
    x = rand.to_s
    @q.put x
    @q.take.should == x
  end
end
