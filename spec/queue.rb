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

  should 'put' do
    x = rand
    @q.put x
    @q.take.should == x.to_s
  end

  should 'take' do
    x = rand
    @q.put x
    @q.take.should == x.to_s
  end

  should 'put multiple' do
    n = 10
    xs = (0...n).map do
      rand.to_s
    end
    @q.put xs

    (0...n).inject([]) do |taken, i|
      taken << @q.take
    end.should == xs
  end

  should 'offer' do
    x = rand
    @q.offer x
    @q.take.should == x.to_s
  end

  should 'poll' do
    x = rand.to_s
    @q.poll.should == nil
    @q.put x
    @q.poll.should == x

    x = rand.to_s
    reader = Thread.new do
      @q.poll(1).should == x
    end

    @q.put x
    reader.join
  end

  should 'commit a transaction' do
    @q << 'a'
    @q << 'b'
    @q.transaction do |t|
      t.take.should == 'a'
      t.take.should == 'b'
      t << '1'
      t << '2'
    end
    @q.take.should == '1'
    @q.take.should == '2'
  end

  should 'roll back a transaction' do
    @q << 'a'
    @q << 'b'
    begin
      @q.transaction do |t|
        t.take.should == 'a'
        t.take.should == 'b'
        t << '1'
        t << '2'
        raise 'oh snap!'
      end
    rescue
    end
    @q.take.should == 'a'
    @q.take.should == 'b'
  end

  should 'thread transactions' do
    n = 100
    @q << (1..n)

    threads = (0...n).map do
      Thread.new do
        @q.transaction do |t|
          (1..n).should.include t.take.to_i
          t << Thread.current
        end
      end
    end

    threads.each do |thread|
      thread.join
    end

    final = Set.new
    while x = @q.poll
      final << x
    end
    threads.map(&:to_s).to_set.should == final
  end
end
