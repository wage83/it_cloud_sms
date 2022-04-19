require 'active_support'
require 'global_phone'
require 'net/https'

module ItCloudSms

  APIUri = URI.parse("https://contacto-masivo.com/sms/back_sms/public/api/sendsms")

  class << self

    @@login = ""
    @@password = ""
    @@from = ""

    def login=(username)
      @@login = username
    end

    def password=(secret)
      @@password = secret
    end

    # Send a petition to ItCloud SMS gateway
    # 
    # Example:
    #   >> ItCloudSms.send_sms(:login => "login",
    #                          :password => "password", 
    #                          :destination => "+573102111111" || ["+573102111111", "+573102111112"], # Up to 5000 numbers
    #                          :message => "Message with 765 chars maximum")
    def send_sms(options = {})
      # Check for login
      login = options[:login] || @@login
      raise ArgumentError, "Login must be present" unless login and not login.blank?

      # Check for password
      password = options[:password] || @@password
      raise ArgumentError, "Password must be present" unless password and not password.blank?

      # Multiple destinations support
      options[:destination] = [options[:destination]] unless options[:destination].kind_of?(Array)

      # Check for max destinations
      raise ArgumentError, "Max of 5000 destinations exceeded" if (options[:destination].size > 5000)

      destinations = []
      options[:destination].each do |phone|
        raise ArgumentError, "Recipient must be a telephone number with international format: #{phone.to_s}" unless parsed = GlobalPhone.parse(phone.to_s)
        if parsed.international_string.to_s =~ /^\+1/
          destinations << parsed.international_string.gsub(/^\+1/, "01") # Replace initial +1 with 01 for IT Cloud requirements
        else
          destinations << parsed.international_string.gsub("+", "") # Remove + from international string
        end
      end

      message = options[:message].to_s
      raise ArgumentError, "Message must be present" if message.blank?
      raise ArgumentError, "Message is 765 chars maximum" if message.size > 765

      http = Net::HTTP.new(APIUri.host, APIUri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request = Net::HTTP::Post.new(APIUri.request_uri)
      request.set_form_data({'user' => login,
                             'token' => password,
                             'GSM' => destinations.join(","),
                             'SMSText' => message,
                             'metodo_envio' => '1via'})

      response = http.request(request)
      if response.code == "200"
        begin
          result = response.body.split("<br>").map{ |a| a.split(",") }.map{ |res| {:telephone => res[0].strip, :code => res[1].strip }}
        rescue
          # Try to get petition result
          result = [{:code => response.body}]
        end
        result.each do |destination|
          case destination[:code]
          when "-1" then
            destination[:description] = "Authentication failed"
          when "-2" then
            destination[:description] = "Out of hours"
          when "-3" then
            destination[:description] = "No credit"
          when "-4" then
            destination[:description] = "Wrong number"
          when "-5" then
            destination[:description] = "Wrong message"
          when "-6" then
            destination[:description] = "System under maintenance"
          when "-7" then
            destination[:description] = "Max cellphones reached"
          when "-8" then
            destination[:description] = "Cellphone number in black list"
          when "-9" then
            destination[:description] = "message rejected for content"
          when "-10" then
            destination[:description] = "Message with no link authorized"
          when "-11" then
            destination[:description] = "Error in metodo_envio variable"
          else
            if destination[:code].to_i > 0
              destination[:description] = "OK"
            else
              destination[:description] = "Unknown error"
            end
          end
        end
        return result
      else
        raise RuntimeError, "Server responded with code #{response.code}: #{response.body}"
      end
    end

  end
end