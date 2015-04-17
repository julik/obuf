# obuf

[![Build Status](https://travis-ci.org/julik/obuf.svg?branch=master)](https://travis-ci.org/julik/obuf)

A simple Ruby object buffer. Use this if you need to temporarily store alot of serializable Ruby objects.

    obuf = Obuf.new
    5_000_000.times{  obuf.push(compute_some_object) } # no memory inflation
    obuf.each do | stored_object | # objects are restored one by one
      # do something with stored_object
    end

You can also write objects in one process, and recover them in another, using `Obuf::Lens`:

    # In fork process
    File.open('/tmp/output.bin', 'a') do |f|
      Obuf::Lens.new(f) << my_object
    end
    
    # In join process after forks completed
    File.open('/tmp/output.bin', 'r') do |f|
      Obuf::Lens.new(f).each do | object_written_by_fork |
        puts object_written_by_fork.inspect
      end
    end

The `Lens` is what is used under the hood in the main Obuf as well.

## Requirements

* Ruby 1.8.6+

## Installation

* gem install obuf

## License

(The MIT License)

Copyright (c) 2011-2015 Julik Tarkhanov <me@julik.nl>

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
