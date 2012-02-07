
#    Copyright © 2011 Brandon L Black <blblack@gmail.com>
#
#    This file is part of gdnsd.
#
#    gdnsd is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    gdnsd is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with gdnsd.  If not, see <http://www.gnu.org/licenses/>.
#

# Basic geoip plugin tests

use _GDT ();
use FindBin ();
use File::Spec ();
use Test::More tests => 44 * 2;

my $soa = 'example.com 86400 SOA ns1.example.com hostmaster.example.com 1 7200 1800 259200 900';

# We re-run the same suite of tests against
#  multiple config files with identical meaning,
#  expressed in different ways.  For example,
#  inherited vs directly-specified attributes
#  at various levels, and synthesized subplugin
#  config versus direct reference.

my @cfgs = (qw/gdnsd.conf gdnsd2.conf/);

foreach my $cfg (@cfgs) { # loop ends at bottom of file

my $pid = _GDT->test_spawn_daemon(File::Spec->catfile($FindBin::Bin, $cfg), q{
    0.0.0.0/1 => US
    128.0.0.0/1 => FR
});

_GDT->test_dns(
    qname => 'example.com', qtype => 'NS',
    answer => 'example.com 86400 NS ns1.example.com',
    addtl => 'ns1.example.com 86400 A 192.0.2.1',
);

# res1
_GDT->test_dns(
    qname => 'res1.example.com', qtype => 'A',
    answer => 'res1.example.com 86400 A 192.0.2.1',
    stats => [qw/udp_reqs noerror/],
);
_GDT->test_dns(
    qname => 'res1.example.com', qtype => 'A',
    q_optrr => _GDT::optrr_clientsub(addr_v4 => '10.10.0.0', src_mask => 16),
    answer => 'res1.example.com 86400 A 192.0.2.1',
    addtl => _GDT::optrr_clientsub(addr_v4 => '10.10.0.0', src_mask => 16, scope_mask => 1),
    stats => [qw/udp_reqs edns edns_clientsub noerror/],
);
_GDT->test_dns(
    qname => 'res1.example.com', qtype => 'A',
    q_optrr => _GDT::optrr_clientsub(addr_v4 => '192.0.2.1', src_mask => 32),
    answer => [ 'res1.example.com 86400 A 192.0.2.5', 'res1.example.com 86400 A 192.0.2.6' ],
    addtl => _GDT::optrr_clientsub(addr_v4 => '192.0.2.1', src_mask => 32, scope_mask => 1),
    stats => [qw/udp_reqs edns edns_clientsub noerror/],
);

#res1/na
_GDT->test_dns(
    qname => 'res1na.example.com', qtype => 'A',
    answer => 'res1na.example.com 86400 A 192.0.2.1',
    stats => [qw/udp_reqs noerror/],
);
_GDT->test_dns(
    qname => 'res1na.example.com', qtype => 'A',
    answer => 'res1na.example.com 86400 A 192.0.2.1',
    q_optrr => _GDT::optrr_clientsub(addr_v4 => '192.0.2.1', src_mask => 32),
    addtl => _GDT::optrr_clientsub(addr_v4 => '192.0.2.1', src_mask => 32, scope_mask => 0),
    stats => [qw/udp_reqs edns edns_clientsub noerror/],
);

#res1/sa
_GDT->test_dns(
    qname => 'res1sa.example.com', qtype => 'A',
    answer => [ 'res1sa.example.com 86400 A 192.0.2.4', 'res1sa.example.com 86400 A 192.0.2.3' ],
    stats => [qw/udp_reqs noerror/],
);
_GDT->test_dns(
    qname => 'res1sa.example.com', qtype => 'A',
    answer => [ 'res1sa.example.com 86400 A 192.0.2.4', 'res1sa.example.com 86400 A 192.0.2.3' ],
    q_optrr => _GDT::optrr_clientsub(addr_v4 => '192.0.2.1', src_mask => 15),
    addtl => _GDT::optrr_clientsub(addr_v4 => '192.0.2.1', src_mask => 15, scope_mask => 0),
    stats => [qw/udp_reqs edns edns_clientsub noerror/],
);

#res1/eu
_GDT->test_dns(
    qname => 'res1eu.example.com', qtype => 'A',
    answer => [ 'res1eu.example.com 86400 A 192.0.2.5', 'res1eu.example.com 86400 A 192.0.2.6' ],
    stats => [qw/udp_reqs noerror/],
);
_GDT->test_dns(
    qname => 'res1eu.example.com', qtype => 'A',
    answer => [ 'res1eu.example.com 86400 A 192.0.2.5', 'res1eu.example.com 86400 A 192.0.2.6' ],
    q_optrr => _GDT::optrr_clientsub(addr_v4 => '192.0.2.1', src_mask => 15),
    addtl => _GDT::optrr_clientsub(addr_v4 => '192.0.2.1', src_mask => 15, scope_mask => 0),
    stats => [qw/udp_reqs edns edns_clientsub noerror/],
);

#res1/ap
_GDT->test_dns(
    qname => 'res1ap.example.com', qtype => 'A',
    answer => [ 'res1ap.example.com 86400 A 192.0.2.7', 'res1ap.example.com 86400 A 192.0.2.8', 'res1ap.example.com 86400 A 192.0.2.9' ],
    stats => [qw/udp_reqs noerror/],
);
_GDT->test_dns(
    qname => 'res1ap.example.com', qtype => 'A',
    answer => [ 'res1ap.example.com 86400 A 192.0.2.7', 'res1ap.example.com 86400 A 192.0.2.8', 'res1ap.example.com 86400 A 192.0.2.9' ],
    q_optrr => _GDT::optrr_clientsub(addr_v4 => '192.0.2.1', src_mask => 1),
    addtl => _GDT::optrr_clientsub(addr_v4 => '192.0.2.1', src_mask => 1, scope_mask => 0),
    stats => [qw/udp_reqs edns edns_clientsub noerror/],
);

# res2
_GDT->test_dns(
    qname => 'res2.example.com', qtype => 'A',
    answer => [],
    auth => $soa,
    addtl => 'res2.example.com 86400 AAAA 2001:DB8::11',
    stats => [qw/udp_reqs noerror/],
);
_GDT->test_dns(
    qname => 'res2.example.com', qtype => 'A',
    q_optrr => _GDT::optrr_clientsub(addr_v4 => '10.10.0.0', src_mask => 16),
    answer => [], auth => $soa,
    addtl => [
        'res2.example.com 86400 AAAA 2001:DB8::11',
        _GDT::optrr_clientsub(addr_v4 => '10.10.0.0', src_mask => 16, scope_mask => 1),
    ],
    stats => [qw/udp_reqs edns edns_clientsub noerror/],
);
_GDT->test_dns(
    qname => 'res2.example.com', qtype => 'A',
    q_optrr => _GDT::optrr_clientsub(addr_v4 => '192.0.2.1', src_mask => 32),
    answer => 'res2.example.com 86400 A 192.0.2.10',
    addtl => [
        'res2.example.com 86400 AAAA 2001:DB8::10',
        _GDT::optrr_clientsub(addr_v4 => '192.0.2.1', src_mask => 32, scope_mask => 1),
    ],
    stats => [qw/udp_reqs edns edns_clientsub noerror/],
);

#res2/dc1
_GDT->test_dns(
    qname => 'res2dc1.example.com', qtype => 'A',
    answer => 'res2dc1.example.com 86400 A 192.0.2.10',
    addtl => 'res2dc1.example.com 86400 AAAA 2001:DB8::10',
    stats => [qw/udp_reqs noerror/],
);
_GDT->test_dns(
    qname => 'res2dc1.example.com', qtype => 'A',
    q_optrr => _GDT::optrr_clientsub(addr_v4 => '192.0.2.1', src_mask => 32),
    answer => 'res2dc1.example.com 86400 A 192.0.2.10',
    addtl => [
        'res2dc1.example.com 86400 AAAA 2001:DB8::10',
        _GDT::optrr_clientsub(addr_v4 => '192.0.2.1', src_mask => 32, scope_mask => 0),
    ],
    stats => [qw/udp_reqs edns edns_clientsub noerror/],
);

#res2/dc2
_GDT->test_dns(
    qname => 'res2dc2.example.com', qtype => 'A',
    answer => [], auth => $soa,
    addtl => 'res2dc2.example.com 86400 AAAA 2001:DB8::11',
    stats => [qw/udp_reqs noerror/],
);
_GDT->test_dns(
    qname => 'res2dc2.example.com', qtype => 'A',
    q_optrr => _GDT::optrr_clientsub(addr_v4 => '192.0.2.1', src_mask => 32),
    answer => [], auth => $soa,
    addtl => [
        'res2dc2.example.com 86400 AAAA 2001:DB8::11',
        _GDT::optrr_clientsub(addr_v4 => '192.0.2.1', src_mask => 32, scope_mask => 0),
    ],
    stats => [qw/udp_reqs edns edns_clientsub noerror/],
);

#res2/dc3
_GDT->test_dns(
    qname => 'res2dc3.example.com', qtype => 'A',
    answer => 'res2dc3.example.com 86400 A 192.0.2.11',
    stats => [qw/udp_reqs noerror/],
);
_GDT->test_dns(
    qname => 'res2dc3.example.com', qtype => 'A',
    q_optrr => _GDT::optrr_clientsub(addr_v4 => '192.0.2.1', src_mask => 32),
    answer => 'res2dc3.example.com 86400 A 192.0.2.11',
    addtl => _GDT::optrr_clientsub(addr_v4 => '192.0.2.1', src_mask => 32, scope_mask => 0),
    stats => [qw/udp_reqs edns edns_clientsub noerror/],
);

#res3
_GDT->test_dns(
    qname => 'res3.example.com', qtype => 'A',
    answer => 'res3.example.com 86400 CNAME dc2cn.example.com',
    auth => $soa, 
    addtl => 'dc2cn.example.com 86400 AAAA 2001:DB8::101',
    stats => [qw/udp_reqs noerror/],
);
_GDT->test_dns(
    qname => 'res3.example.com', qtype => 'A',
    q_optrr => _GDT::optrr_clientsub(addr_v4 => '10.10.0.0', src_mask => 16),
    answer => 'res3.example.com 86400 CNAME dc2cn.example.com',
    auth => $soa, 
    addtl => [
        'dc2cn.example.com 86400 AAAA 2001:DB8::101',
        _GDT::optrr_clientsub(addr_v4 => '10.10.0.0', src_mask => 16, scope_mask => 1),
    ],
    stats => [qw/udp_reqs edns edns_clientsub noerror/],
);
_GDT->test_dns(
    qname => 'res3.example.com', qtype => 'A',
    q_optrr => _GDT::optrr_clientsub(addr_v4 => '192.0.2.1', src_mask => 32),
    answer => [ 
        'res3.example.com 86400 CNAME dc1cn.example.com',
        'dc1cn.example.com 86400 A 192.0.2.100',
    ],
    addtl => [
        _GDT::optrr_clientsub(addr_v4 => '192.0.2.1', src_mask => 32, scope_mask => 1),
    ],
    stats => [qw/udp_reqs edns edns_clientsub noerror/],
);

#res3/dc1
_GDT->test_dns(
    qname => 'res3dc1.example.com', qtype => 'A',
    answer => [
        'res3dc1.example.com 86400 CNAME dc1cn.example.com',
        'dc1cn.example.com 86400 A 192.0.2.100',
    ],
    stats => [qw/udp_reqs noerror/],
);
_GDT->test_dns(
    qname => 'res3dc1.example.com', qtype => 'A',
    q_optrr => _GDT::optrr_clientsub(addr_v4 => '192.0.2.1', src_mask => 32),
    answer => [ 
        'res3dc1.example.com 86400 CNAME dc1cn.example.com',
        'dc1cn.example.com 86400 A 192.0.2.100',
    ],
    addtl => _GDT::optrr_clientsub(addr_v4 => '192.0.2.1', src_mask => 32, scope_mask => 0),
    stats => [qw/udp_reqs edns edns_clientsub noerror/],
);

#res3/dc2
_GDT->test_dns(
    qname => 'res3dc2.example.com', qtype => 'A',
    answer => 'res3dc2.example.com 86400 CNAME dc2cn.example.com',
    auth => $soa, 
    addtl => 'dc2cn.example.com 86400 AAAA 2001:DB8::101',
    stats => [qw/udp_reqs noerror/],
);
_GDT->test_dns(
    qname => 'res3dc2.example.com', qtype => 'A',
    q_optrr => _GDT::optrr_clientsub(addr_v4 => '10.10.0.0', src_mask => 16),
    answer => 'res3dc2.example.com 86400 CNAME dc2cn.example.com',
    auth => $soa, 
    addtl => [
        'dc2cn.example.com 86400 AAAA 2001:DB8::101',
        _GDT::optrr_clientsub(addr_v4 => '10.10.0.0', src_mask => 16, scope_mask => 0),
    ],
    stats => [qw/udp_reqs edns edns_clientsub noerror/],
);

#res3/dc3
_GDT->test_dns(
    qname => 'res3dc3.example.com', qtype => 'A',
    answer => [
        'res3dc3.example.com 86400 CNAME dc3cn.example.com',
        'dc3cn.example.com 86400 A 192.0.2.102',
    ],
    addtl => 'dc3cn.example.com 86400 AAAA 2001:DB8::102',
    stats => [qw/udp_reqs noerror/],
);
_GDT->test_dns(
    qname => 'res3dc3.example.com', qtype => 'A',
    q_optrr => _GDT::optrr_clientsub(addr_v4 => '10.10.0.0', src_mask => 16),
    answer => [
        'res3dc3.example.com 86400 CNAME dc3cn.example.com',
        'dc3cn.example.com 86400 A 192.0.2.102',
    ],
    addtl => [
        'dc3cn.example.com 86400 AAAA 2001:DB8::102',
        _GDT::optrr_clientsub(addr_v4 => '10.10.0.0', src_mask => 16, scope_mask => 0),
    ],
    stats => [qw/udp_reqs edns edns_clientsub noerror/],
);

#dmx
_GDT->test_dns(
    qname => 'dmx.example.com', qtype => 'MX',
    answer => [
        'dmx.example.com 86400 MX 0 res1.example.com',
        'dmx.example.com 86400 MX 1 res2.example.com',
        'dmx.example.com 86400 MX 2 res3.example.com',
    ],
    addtl => [
        'res1.example.com 86400 A 192.0.2.1',
        'res2.example.com 86400 AAAA 2001:DB8::11',
    ],
    stats => [qw/udp_reqs noerror/],
);
_GDT->test_dns(
    qname => 'dmx.example.com', qtype => 'MX',
    q_optrr => _GDT::optrr_clientsub(addr_v4 => '192.0.2.1', src_mask => 32),
    answer => [
        'dmx.example.com 86400 MX 0 res1.example.com',
        'dmx.example.com 86400 MX 1 res2.example.com',
        'dmx.example.com 86400 MX 2 res3.example.com',
    ],
    addtl => [
       'res1.example.com 86400 A 192.0.2.5',
        'res1.example.com 86400 A 192.0.2.6',
        'res2.example.com 86400 A 192.0.2.10',
        'res2.example.com 86400 AAAA 2001:DB8::10',
        _GDT::optrr_clientsub(addr_v4 => '192.0.2.1', src_mask => 32, scope_mask => 1),
    ],
    stats => [qw/udp_reqs edns edns_clientsub noerror/],
);

# limited dynamic AAAA
_GDT->test_dns(
    qname => 'res4.example.com', qtype => 'AAAA',
    answer => [
        'res4.example.com 86400 AAAA 2001:DB8::2:123',
        'res4.example.com 86400 AAAA 2001:DB8::2:456',
        'res4.example.com 86400 AAAA 2001:DB8::2:789',
    ],
    limit_v6 => 2,
    stats => [qw/udp_reqs noerror/],
);

# over-limited dynamic AAAA
_GDT->test_dns(
    qname => 'res4-lots.example.com', qtype => 'AAAA',
    answer => [
        'res4-lots.example.com 86400 AAAA 2001:DB8::2:123',
        'res4-lots.example.com 86400 AAAA 2001:DB8::2:456',
        'res4-lots.example.com 86400 AAAA 2001:DB8::2:789',
    ],
    stats => [qw/udp_reqs noerror/],
);

# DYNC that loops on itself until max_cname_depth (16) is reached...
_GDT->test_dns(
    qname => 'res5.example.com', qtype => 'AAAA',
    header => { rcode => 'NXDOMAIN' },
    answer => [],
    auth => $soa,
    stats => [qw/udp_reqs nxdomain/],
);

#geoip + weighted
_GDT->test_dns(
    qname => 'res6.example.com', qtype => 'A',
    wrr_v4 => { 'res6.example.com' => { multi => 0, groups => [ 3, 3 ] } },
    answer => [
        'res6.example.com 86400 A 192.0.2.121',
        'res6.example.com 86400 A 192.0.2.122',
        'res6.example.com 86400 A 192.0.2.123',
        # -- group break --
        'res6.example.com 86400 A 192.0.2.221',
        'res6.example.com 86400 A 192.0.2.222',
        'res6.example.com 86400 A 192.0.2.223',
    ],
    stats => [qw/udp_reqs noerror/],
);
_GDT->test_dns(
    qname => 'res6.example.com', qtype => 'A',
    q_optrr => _GDT::optrr_clientsub(addr_v4 => '192.0.2.1', src_mask => 32),
    limit_v4 => 1,
    answer => [
        'res6.example.com 86400 A 192.0.2.111',
        'res6.example.com 86400 A 192.0.2.112',
        'res6.example.com 86400 A 192.0.2.113',
    ],
    addtl => _GDT::optrr_clientsub(addr_v4 => '192.0.2.1', src_mask => 32, scope_mask => 1),
    stats => [qw/udp_reqs edns edns_clientsub noerror/],
);

#geoip DYNC weighted
_GDT->test_dns(
    qname => 'res7.example.com', qtype => 'A',
    # CNAME auto-limits to 1 RR
    answer => [
        'res7.example.com 86400 CNAME www1.example.org',
        'res7.example.com 86400 CNAME www2.example.org',
    ],
    stats => [qw/udp_reqs noerror/],
);
_GDT->test_dns(
    qname => 'res7.example.com', qtype => 'A',
    q_optrr => _GDT::optrr_clientsub(addr_v4 => '192.0.2.1', src_mask => 32),
    # CNAME auto-limits to 1 RR
    answer => [
        'res7.example.com 86400 CNAME www1.example.net',
        'res7.example.com 86400 CNAME www2.example.net',
    ],
    addtl => _GDT::optrr_clientsub(addr_v4 => '192.0.2.1', src_mask => 32, scope_mask => 1),
    stats => [qw/udp_reqs edns edns_clientsub noerror/],
);

# failover, dc1 -> dc2
_GDT->test_dns(
    qname => 'res8.example.com', qtype => 'A',
    q_optrr => _GDT::optrr_clientsub(addr_v4 => '192.0.2.1', src_mask => 32),
    answer => [
        'res8.example.com 86400 A 192.0.2.92',
        'res8.example.com 86400 A 192.0.2.93',
    ],
    addtl => _GDT::optrr_clientsub(addr_v4 => '192.0.2.1', src_mask => 32, scope_mask => 1),
    stats => [qw/udp_reqs edns edns_clientsub noerror/],
);

# geoip -> metafo
_GDT->test_dns(
    qname => 'res9.example.com', qtype => 'A',
    answer => [
        'res9.example.com 86400 A 192.0.2.92',
        'res9.example.com 86400 A 192.0.2.93',
    ],
    stats => [qw/udp_reqs noerror/],
);
_GDT->test_dns(
    qname => 'res9.example.com', qtype => 'A',
    q_optrr => _GDT::optrr_clientsub(addr_v4 => '192.0.2.1', src_mask => 32),
    answer => 'res9.example.com 86400 A 192.0.2.142',
    addtl => _GDT::optrr_clientsub(addr_v4 => '192.0.2.1', src_mask => 32, scope_mask => 1),
    stats => [qw/udp_reqs edns edns_clientsub noerror/],
);

_GDT->test_kill_daemon($pid);
}
