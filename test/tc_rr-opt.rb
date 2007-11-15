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
require 'test/unit'
require 'dnsruby'
require 'socket.so'
include Dnsruby
class TestRrOpt < Test::Unit::TestCase
  def test_rropt
    size=2048;
    ednsflags=0x9e22;
    
    optrr = RR::OPT.new(size, ednsflags)
    
    assert(optrr.d_o,"DO bit set")
    optrr.d_o=false
    assert_equal(optrr.flags,0x1e22,"Clearing do, leaving the other bits ");
    assert(!optrr.d_o,"DO bit cleared")
    optrr.d_o=true
    assert_equal(optrr.flags,0x9e22,"Clearing do, leaving the other bits ");
    
    
    assert_equal(optrr.payloadsize,2048,"Size read")
    assert_equal(optrr.payloadsize=(1498),1498,"Size set")
    
  end
  
  def test_resolver_opt_application
    # Set up a server running on localhost. Get the resolver to send a
    # query to it with the UDP size set to 4096. Make sure that it is received
    # correctly.
    socket = UDPSocket.new
    socket.bind("127.0.0.1", 0)
    port = socket.addr[1]
    q = Queue.new
    Thread.new {
      s = socket.recvfrom(65536)
      print s.length
      received_query = s[0]
      socket.connect(s[1][2], s[1][1])
      q.push(Message.decode(received_query))
      socket.send(received_query,0)
    }
    
    # Now send query
    res = Resolver.new("127.0.0.1")
    res.port = port
    res.udp_size = 4096
    assert(res.udp_size == 4096)
    res.query("example.com")
    
    # Now get received query from the server
    p = q.pop
    # Now check the query was what we expected
    assert(p.header.arcount == 1)
    assert(p.additional()[0].type = Types.OPT)
    assert(p.additional()[0].klass.code == 4096)
  end
  
  def test_large_packet
    # Query TXT for overflow.dnsruby.validation-test-servers.nominet.org.uk
    # with a large udp_size
    res = SingleResolver.new
    res.udp_size = 4096
    ret = res.query("overflow.dnsruby.validation-test-servers.nominet.org.uk", Types.TXT)
    assert(ret.header.rcode == RCode.NoError)
  end
end
