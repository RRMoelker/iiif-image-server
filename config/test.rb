#!/usr/bin/env ruby

require './delegates'

obj = CustomDelegate.new
obj.context = {
  'identifier' => 'objectstore:beeldbank-B00000026214.jpg',
  'client_ip' => '127.0.0.1'
}

puts obj.source