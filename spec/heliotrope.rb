#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib', 'heliotrope'))
require 'bacon'

Bacon.summary_on_exit 

include Heliotrope

describe Heliotrope::Client do
  should 'set up' do
    Client.new.connection.should == 
      Connection.new(host: '127.0.0.1')
    
    Client.new(host: 'foo').connection.should == 
      Connection.new(host: 'foo')
    
    c = Client.new(hosts: ['foo', 'bar']).connection
    (
      c == Connection.new(host: 'foo') or
      c == Connection.new(host: 'bar')
    ).should.be.true
    
    c = Client.new(connections: [
      {host: 'foo'},
      {host: 'bar'}
    ]).connection
    (
      c == Connection.new(host: 'foo') or
      c == Connection.new(host: 'bar')
    ).should.be.true
  end
end
