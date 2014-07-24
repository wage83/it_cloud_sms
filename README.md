IT Cloud SMS
===========

Provides a gateway to use IT Cloud Colombia SMS service over HTTP POST

Usage
-----

    ItCloudSms.send_sms(:login => "login",
                        :password => "password", 
                        :destination => "0057.." || ["0057...","0057..."],
                        :message => "Message with 159 chars maximum")

- __Login__: supplied by IT Cloud Colombia.
- __Password__: supplied by IT Cloud Colombia.
- __Destination__: destination numbers, international format. If an Array is passed, SMS will be sent to all numbers.
- __Message__: Message to send, maximum 159 characters.

If petition is sent correctly, it will return an array of hashes that contains the operation code, destination number and code description. Otherwise, an Exception will be raised:

    [{:description=>"OK", :telephone=>"57...", :code=>"00001"}, {:description=>"Operator not found", :telephone=>"57...", :code=>"0"}]

Posible codes are:

- __0__: Operator not found
- __-1__: Authentication failed
- __-2__: Out of hours
- __-3__: No credit
- __-4__: Wrong number
- __-5__: Wrong message
- __-6__: System under maintenance
- __-7__: Max cellphones reached

Every code above 0, refers to operation code result.

More information
----------------

http://www.itcloudcolombia.com/?page_id=23

- Copyright (c) 2014 Angel García Pérez
