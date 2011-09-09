#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib', 'heliotrope'))
require 'bacon'

Bacon.summary_on_exit 

include Heliotrope

describe Heliotrope::Client do
  should 'set up' do
    Client.new.connections.should == 
      [Connection.new(host: '127.0.0.1')]
    
    Client.new(host: 'foo').connections.should == 
      [Connection.new(host: 'foo')]
    
    Client.new(hosts: ['foo', 'bar']).connections.should == 
      [
        Connection.new(host: 'foo'),
        Connection.new(host: 'bar')
      ]
    
    Client.new(connections: [
      {host: 'foo'},
      {host: 'bar'}
    ]).connections.should == 
      [
        Connection.new(host: 'foo'),
        Connection.new(host: 'bar')
      ]
  end
end
