extends: post.liquid
title: BadBill - a Billomat API client
date: 21 Sep 2012 12:58:00 +0200
path: /:year/:month/:day/badbilla-billomat-api-client
---
I'm happy to announce the release of my Billomat API client:

## [BadBill][repo]

BadBill is a simple API client for the [Billomat API][apidocu].
It allows access to all resources the API offers.

For now only `clients` and `invoices` are pure Ruby classes, but all other resources are available trough an easy interface returning Hash-like objects.

My goals for this project:

* Fast and easy access to all resources the API provides
  (not all resources are Ruby classes, yet)
* Full documentation.
* Test coverage as best as I can.
* Production-ready (it's for a job project).

I'm sure it may include bugs and it's not ready for all use-cases,
but as this is open-source now I accept all ideas, improvements, bug reports and pull-requests.
Just go to the [Github repository][repo] and start hacking. ;)

Install it via Rubygems:

    gem install badbill

Read the documentation online: [BadBill documentation](http://rubydoc.info/github/badboy/badbill/master/frames)

And now for some code examples:

#### Basic interface:

~~~ruby
bill = BadBill.new "billo", "18e40e14"
# => #<BadBill:0x00000001319d30 ...>
bill.get 'settings'
# => {"settings"=>
#   {"invoice_intro"=>"",
#    "invoice_note"=>"",
#    ...}}
~~~

#### Using defined resources classes:

~~~ruby
BadBill.new "billo", "18e40e14"

BadBill::Invoice.all
# => [#<BadBill::Invoice:0x000000024caf98 @id="1" @data={...}>], ...]

invoice = BadBill::Invoice.find(1)
invoice.pdf
# => {"id"=>"1",
#     "created"=>"2012-09-17T13:58:42+02:00",
#     "invoice_id"=>"322791",
#     "filename"=>"Invoice 322791.pdf",
#     "mimetype"=>"application/pdf",
#     "filesize"=>"90811",
#     "base64file"=>"JVBERi0xLjM..."}
invoice.delete
# => true
~~~

[repo]: https://github.com/badboy/badbill
[apidocu]: http://www.billomat.com/en/api/
