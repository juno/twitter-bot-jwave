# J-WAVE NOW ON-AIR Bluesky bot

## DESCRIPTION

This bot posts about songs which aired from the Japanese Radio Station "J-WAVE" to Bluesky.
Song information will fetched from http://www.j-wave.co.jp/alladdin/ .


## SETUP

Install redis.

    $ brew install redis

Bundle gems.

    $ bundle install --path .bundle

Create and edit `.env` file to set Redis URL and Bluesky credentials.

    $ cp example.env .env
    $ vi .env

Set `BLUESKY_IDENTIFIER` (e.g., `username.bsky.social`) and `BLUESKY_APP_PASSWORD` (generate from Bluesky settings).


## USAGE

    $ redis-server &
    $ heroku local


## DEPLOYMENT TO RENDER

This bot is configured to deploy to Render.com.

Set configuration environment variables in Render dashboard:

    BLUESKY_IDENTIFIER="username.bsky.social"
    BLUESKY_APP_PASSWORD="your-app-password"
    REDIS_URL="redis://..."

Deployment is automatic on git push to main branch.


CONTACT
-----

*  Junya Ogura - https://twitter.com/junya


LICENSE
----

(The MIT License)

Copyright (c) Junya Ogura

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
