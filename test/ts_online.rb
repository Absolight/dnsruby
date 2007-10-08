#--
#Copyright 2007 Nominet UK
#
#Licensed under the Apache License, Version 2.0 (the "License");
#you may not use this file except in compliance with the License. 
#You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0 
#
#Unless required by applicable law or agreed to in writing, software 
#distributed under the License is distributed on an "AS IS" BASIS, 
#WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
#See the License for the specific language governing permissions and 
#limitations under the License.
#++
require 'rubygems'
require "test/unit"
require 'Dnsruby'
# Disable these tests if we're not online
require 'socket'
sock = UDPSocket.new()
begin
  sock.connect('193.0.14.129', # k.root-servers.net.
    25)
  # OK - online and ready to go
  require "test/tc_res_config.rb"
  require "test/tc_single_resolver.rb"
  require "test/tc_resolver.rb"
  require "test/tc_dns.rb"
  require "test/tc_dnsruby.rb"
  #  require "test/tc_inet6.rb"
  #  require "test/tc_recurse.rb"
  require "test/tc_tcp.rb"
  #  require "test/tc_soak.rb"
  require "test/tc_axfr.rb" #@TODO@
  begin
    require 'eventmachine'
    require 'test/tc_event_machine_single_res.rb'
    require 'test/tc_event_machine_res.rb'
    require 'test/tc_event_machine_deferrable.rb'
  rescue LoadError => e
    puts "EventMachine not installed - skipping test"
  end
rescue Exception
  puts "Cannot bind to socket:\n\t"+$!+"\n"
  puts "This is an indication you have network problems\n"
  puts "\n\nNo online tests will be run!!\n\n"
end