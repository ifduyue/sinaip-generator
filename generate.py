#!/usr/bin/env python

import struct
import sys
import os
try:
    import simplejson as json
except ImportError:
    import json

from iptools.ipv4 import ip2long

if len(sys.argv) == 3:
    filename, output_filename = sys.argv[1:3]
else:
    filename = sys.argv[1]
    output_filename = 'ip.data'

output = open(output_filename, 'wb')
output.write('?'*4)
output.write('?'*4)
output_data = open(output_filename + '.data', 'w+b')

print 'writing output to', output_filename
texts = {}
indexes = []

last = None
with open(filename, 'rb') as f:
    for line in f:
        line = line.strip()
        if not line or line[0] != '{' or line[-1] != '}':
            continue
        js = json.loads(line)
        a = js['start']
        b = js['end']
        country = js['country']
        province = js['province']
        city = js['city']
        district = js['district']
        isp = js['isp']
        type = js['type']
        desc = js['desc']
        country = country.encode('utf8') if country else ''
        province = province.encode('utf8') if province else ''
        city = city.encode('utf8') if city else ''
        isp = isp.encode('utf8') if isp else ''
        this = [country, province, city, isp]
        if last != this:
            last = this
            if country not in texts:
                texts[country] = output.tell()
                v = country + '\0'
                output.write(v)
            if province not in texts:
                texts[province] = output.tell()
                v = province + '\0'
                output.write(v)
            if city not in texts:
                texts[city] = output.tell()
                v = city + '\0'
                output.write(v)
            if isp not in texts:
                texts[isp] = output.tell()
                v = isp + '\0'
                output.write(v)

            output_data.write(struct.pack('<IIII', texts[country],
                                          texts[province], texts[city],
                                          texts[isp]))
            indexes.append(ip2long(a))

texts = {}
print 'texts done.'

offset = output.tell()
output.seek(0, os.SEEK_SET)
output.write(struct.pack('<I', offset))
output.seek(0, os.SEEK_END)

output_data.seek(0, os.SEEK_SET)
chunk = output_data.read()
output.write(chunk)
output_data.close()
os.remove(output_data.name)

print 'data done.'

offset = output.tell()
output.seek(4, os.SEEK_SET)
output.write(struct.pack('<I', offset))

output.seek(0, os.SEEK_END)
packed_indexes = struct.pack('<'+'I'*len(indexes), *indexes)
output.write(packed_indexes)
output.close()
print 'index done.'
