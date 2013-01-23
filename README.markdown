J-WAVE NOW ON-AIR twitter bot
====

DESCRIPTION
----

This bot is post current track of Japanese radio station J-WAVE.
Track information fetch from http://www.j-wave.co.jp/alladdin/


PREREQUISITE
----

    $ bundle


USAGE
----

Edit config.yml and set Bit.ly and Twitter OAuth API keys.

    $ vi config.xml

Create cache file and set permissions.

    $ touch cache.txt
    $ chmod 644 cache.txt

Run script.

    $ bundle exec ruby ruby-jwave.rb


CONTACT
-----

*  Junya Ogura <junyaogura@gmail.com>
*  twitter.com/junya


LICENSE
----

(The MIT License)

Copyright (c) 2010-2011 Junya Ogura

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
