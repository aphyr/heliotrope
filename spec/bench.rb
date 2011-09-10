#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib', 'heliotrope'))
require 'heliotrope/queue'
require 'bacon'
require 'set'

Bacon.summary_on_exit 

include Heliotrope

describe Heliotrope::Queue do
  before do
    @c = Heliotrope::Client.new(host: ENV['HELIOTROPE_TEST'])
    @q = @c.queue 'heliotrope-test'
    @q.clear
  end

  it 'put' do
    t0 = Time.now
    n = 100
    n.times do
      @q.put 'test'
    end
    dt = Time.now - t0
    r = n / dt
    puts "#{r}/sec"
    r.should > 1
  end
  
  it 'threaded put' do
    t0 = Time.now
    total = 10000
    c = 100
    n = (total.to_f / c).to_i
    total = n * c

    threads = (0...c).map do
      Thread.new do
        n.times do
          @q.put 'test'
        end
      end
    end.each do |thread|
      thread.join
    end

    dt = Time.now - t0
    r = total / dt
    puts "#{r}/sec"
    r.should > 1
  end
end
