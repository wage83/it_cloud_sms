IT Cloud SMS
===========

Provides a gateway to use IT Cloud Colombia SMS service over HTTP POST

Usage
-----

    ItCloudSms.send_sms(:login => "login",
                        :password => "password", 
                        :from => "Max 11chars",
                        :destination => "0034999999999",
                        :message => "Message with 140 chars maximum")

- __Login__: supplied by IT Cloud Colombia.
- __Password__: supplied by IT Cloud Colombia.
- __From__: source SMS. Maximum 11 characters. Could be your company's name or source telephone number.
- __Destination__: destination number, international format.
- __Message__: Message to send, maximum 159 characters.

If message is sent correctly, it will return true. Otherwise, error code is returned.

More information
----------------

http://www.itcloudcolombia.com/?page_id=23

- Copyright (c) 2014 Angel García Pérez
