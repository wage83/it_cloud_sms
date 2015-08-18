require 'active_support'
require 'global_phone'
require 'net/https'

module ItCloudSms

  APIUri = URI.parse("https://sistemasmasivos.com/itcloud/api/sendsms/send.php")

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
    #                          :destination => "+573102111111" || ["+573102111111", "+573102111112"], # Up to 500 numbers
    #                          :message => "Message with 159 chars maximum")
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
      raise ArgumentError, "Max of 500 destinations exceeded" if (options[:destination].size > 500)

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
      raise ArgumentError, "Message is 159 chars maximum" if message.size > 159

      http = Net::HTTP.new(APIUri.host, APIUri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request = Net::HTTP::Post.new(APIUri.request_uri)
      request.set_form_data({'user' => login,
                             'password' => password,
                             'GSM' => destinations.join(","),
                             'SMSText' => message})

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
          when "0" then
            destination[:description] = "Operator not found"
          else
            if destination[:code].to_i == 0
              destination[:description] = "Unknown error"
            else
              destination[:description] = "OK"
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
