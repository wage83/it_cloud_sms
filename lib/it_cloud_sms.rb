require 'phone'
require 'net/https'

module ItCloudSms

  PhoneFormat = "%c%a%n"
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
    #                          :destination => "573102111111" || ["573102111111", "573102111112"], # Up to 500 numbers
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
        raise ArgumentError, "Recipient must be a telephone number with international format: #{phone.to_s}" unless Phoner::Phone.valid?(phone.to_s)
        destinations << Phoner::Phone.parse(phone.to_s).format(PhoneFormat)
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
        case response.body
        when "-1" then
          raise StandardError, "Authentication failed"
        when "-2" then
          raise StandardError, "Out of hours"
        when "-3" then
          raise StandardError, "No credit"
        when "-4" then
          raise StandardError, "Wrong number"
        when "-5" then
          raise StandardError, "Wrong message"
        when "-6" then
          raise StandardError, "System under maintenance"
        when "-7" then
          raise StandardError, "Max cellphones reached"
        when "0" then
          raise StandardError, "Operator not found"
        else
          return response.body
        end
      else
        raise RuntimeError, "Server responded with code #{response.code}: #{response.body}"
      end
    end

  end
end
