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

If message is sent correctly, it will return operation code. Otherwise, an Exception will be raised.

More information
----------------

http://www.itcloudcolombia.com/?page_id=23

- Copyright (c) 2014 Angel García Pérez
