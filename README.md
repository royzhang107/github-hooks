# Technical Spike about Securing your webhooks

## Environment
- ruby: ruby 2.6.8p205
- curl: curl 7.80.0
- xxd: V1.10 27oct98 by Juergen Weigert
- openssl: LibreSSL 2.8.3

## Steps

1. Get secret token in hex. xxd can create a hex dump of a given text.
```bash
$ echo -n "123" | xxd -p -c 32
313233
```

2. Get sha256 signature string
```
$ cat ./payload.json | openssl sha256 -hex -mac HMAC -macopt hexkey:313233
18ff659918e341fa71ab5b0698521615f6337aaade7537d0f836bec8a1123621
```

3. Start to run the sample ruby script: [hook.rb](./hook.rb)
```
$ export SECRET_TOKEN=123
$ gem install sinatra json logger
$ ruby hook.rb
...
== Sinatra (v2.1.0) has taken the stage on 4567 for development with backup from WEBrick
[2021-12-22 19:04:46] INFO  WEBrick::HTTPServer#start: pid=42766 port=4567
```

4. Send the following request to the hook URL, and should get a successful response.
```
$ curl -v --location --request POST 'http://localhost:4567/payload' \
--header 'X-Hub-Signature-256: sha256=18ff659918e341fa71ab5b0698521615f6337aaade7537d0f836bec8a1123621' \
--header 'Content-Type: application/json' \
--data-binary '@./payload.json'

* Connected to localhost (127.0.0.1) port 4567 (#0)
> POST /payload HTTP/1.1
> Host: localhost:4567
...
< HTTP/1.1 200 OK
< Content-Type: text/html;charset=utf-8
< Content-Length: 319
...
I got some JSON: {...}
```
