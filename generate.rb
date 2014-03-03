#!/usr/bin/env ruby

require 'json'
require 'set'
require 'ipaddr'

filename, output_filename = ARGV
output_filename ||= 'ip.dat'
output = File.new(output_filename, 'wb')
output_data = File.new(output_filename + '.data', 'w+b')
File.delete output_data.path
output.write('?' * 4)
output.write('?' * 4)
puts "writing output to #{output_filename}"

texts = Hash.new do |h, k|
  h[k] = output.tell
  output.write([k].pack 'Z*')
  h[k]
end
indexes = []

last = nil
File.new(filename, 'rb').each_line do |line|
  line.strip!
  next if line.empty? || line[0] != '{' || line[-1] != '}'

  js = JSON.parse(line)
  a = js['start']
  b = js['end']
  country = js['country']
  province = js['province']
  city = js['city']
  district = js['district']
  isp = js['isp']
  type = js['type']
  desc = js['desc']
  country ||= ''
  province ||= ''
  city ||= ''
  isp ||= ''
  this = [country, province, city, isp]

  if last != this
    last = this

    s = [texts[country], texts[province], texts[city], texts[isp]].pack 'V*'
    output_data.write s
    indexes << IPAddr.new(a).to_i
  end
end

texts.clear
puts 'texts done.'

offset = output.tell
output.seek 0
output.write([offset].pack 'V')
output.seek 0, IO::SEEK_END

output_data.seek 0
chunk = output_data.read
output.write(chunk)

output_data.close
File.delete output_data.path

puts 'data done.'

offset = output.tell
output.seek 4
output.write([offset].pack 'V')

output.seek 0, IO::SEEK_END
output.write(indexes.pack 'V*')
output.close
puts 'index done.'
