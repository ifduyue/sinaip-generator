#!/usr/bin/env ruby

require 'net/http'
require 'open-uri'
require 'ipaddr'
require 'json'

# reserved ips, see http://en.wikipedia.org/wiki/Reserved_IP_addresses
RESERVED_IPS = [
  IPAddr.new('0.0.0.0/8'),
  IPAddr.new('10.0.0.0/8'),
  IPAddr.new('100.64.0.0/10'),
  IPAddr.new('127.0.0.0/8'),
  IPAddr.new('169.254.0.0/16'),
  IPAddr.new('172.16.0.0/12'),
  IPAddr.new('192.0.0.0/29'),
  IPAddr.new('192.0.2.0/24'),
  IPAddr.new('192.88.99.0/24'),
  IPAddr.new('192.168.0.0/16'),
  IPAddr.new('198.18.0.0/15'),
  IPAddr.new('198.51.100.0/24'),
  IPAddr.new('203.0.113.0/24'),
  IPAddr.new('224.0.0.0/4'),
  IPAddr.new('240.0.0.0/4'),
  IPAddr.new('255.255.255.255/32'),
  # sina special case
  # Couldn't find any ref about it's IANA reserved or unallocated range
  IPAddr.new('169.255.0.0/16')
]

SINA_IP_API = 'http://int.dpool.sina.com.cn/iplookup/iplookup.php?format=json&ip='

def reserved?(ip)
  RESERVED_IPS.each do |reserved|
    return reserved if reserved.include? ip
  end
  false
end

i = 0
loop do
  break if i > 4_294_967_295 # 2^32 - 1

  ip = IPAddr.new(i, Socket::AF_INET)
  puts ip.to_s
  reserved = reserved? ip
  if reserved
    i = reserved.to_range.last.to_i + 1
    a = reserved.to_range.first.to_s
    b = reserved.to_range.last.to_s
    h = {
      ret: 1,
      start: a,
      end: b,
      country: :IANA,
      province: :IANA,
      city: :IANA,
      district: '',
      isp: '',
      type: '',
      desc: ''
    }
    puts h.to_json
    next
  end

  begin
    f = open(SINA_IP_API + ip.to_s,
             'User-agent' => "Mozilla/5.0 (hello,sinard #{i})",
             'Referer' => 'http://finance.sina.com.cn/')
    body = f.read
    puts body
    js = JSON.parse body
    i = js.key?('end') ? IPAddr.new(js['end']).to_i + 1 : i + 1
    next
  rescue
    sleep 10
    retry
  end
end
