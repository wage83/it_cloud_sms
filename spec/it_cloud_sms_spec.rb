require 'spec_helper'

describe ItCloudSms do

  context "when arguments are incorrect" do
    it "should raise an ArgumentError if no login present" do
      proc { ItCloudSms.send_sms(:password => "bar", :destination => "+34666666666", :message => "Lore ipsum") }.should raise_exception(ArgumentError, "Login must be present")
    end

    it "should raise an ArgumentError if no password present" do
      proc { ItCloudSms.send_sms(:login => "foo", :destination => "+34666666666", :message => "Lore ipsum") }.should raise_exception(ArgumentError, "Password must be present")
    end

    it "should raise an ArgumentError if destination is not a valid international number" do
      proc { ItCloudSms.send_sms(:login => "foo", :password => "bar", :destination => "666666666", :message => "Lore ipsum") }.should raise_exception(ArgumentError, "Recipient must be a telephone number with international format: 666666666")
    end

    it "should raise an ArgumentError if no message present" do
      proc { ItCloudSms.send_sms(:login => "foo", :password => "bar", :destination => "+34666666666") }.should raise_exception(ArgumentError, "Message must be present")
    end

    it "should raise an ArgumentError if message is more than 140 characters" do
      proc { ItCloudSms.send_sms(:login => "foo", :password => "bar", :destination => "+34666666666", :message => "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas commodo mattis ligula vitae malesuada. Vestibulum vulputate eros et lacus condimentum suscipit. Nulla cursus orci ac mauris ullamcorper gravida. Nullam neque lacus, facilisis ac tellus eget, congue consectetur turpis. Sed fringilla, dui nec facilisis lobortis, turpis neque volutpat leo, in ultrices orci lacus vel lacus. Sed dapibus tortor sit amet leo vulputate, sit amet facilisis felis fringilla. Nunc ultricies pulvinar nisi, non iaculis nibh condimentum at. In urna ipsum, condimentum quis purus ac, mollis pharetra mi.") }.should raise_exception(ArgumentError, "Message is 159 chars maximum")
    end
  end

  context "when connecting to server" do
    before(:each) do
      @http = Object.new
      @http.stub!("use_ssl=").with(true)
      @http.stub!("verify_mode=").with(anything)
      @request = Object.new
      Net::HTTP.should_receive(:new).with(ItCloudSms::APIUri.host, ItCloudSms::APIUri.port).and_return(@http)
      Net::HTTP::Post.should_receive(:new).with(ItCloudSms::APIUri.request_uri).and_return(@request)
      @request.should_receive(:set_form_data).with(anything)
    end

    it "should return result Hash when sending correctly a petition" do
      destinations = %w(+34666666660 +34666666661 +34666666662 +34666666663 +34666666664 +34666666665 +34666666666 +34666666667 +34666666668)
      response = Object.new
      response.stub!(:code).and_return("200")
      response.stub!(:body).and_return(destinations.each_with_index.map{ |d,i| "#{d},#{i-7}"}.join("<br>"))
      @http.should_receive(:request).with(@request).and_return(response)

      result = ItCloudSms.send_sms(:login => "foo", :password => "bar", :destination => destinations, :message => "Lore ipsum")
      destinations.each_with_index { |d,i|
        result[i][:telephone].should == d
        result[i][:description].should_not be_nil
      }

      # Last destination should return OK
      result.last[:telephone].should == destinations.last
      result.last[:description].should == "OK"
      result.last[:code].should == "1"
    end

    it "should accept login and password for module configuration" do
      # Establish ItCloudSms configuration
      ItCloudSms.login = "foo"
      ItCloudSms.password = "bar"

      response = Object.new
      response.stub!(:code).and_return("200")
      response.stub!(:body).and_return("12345")
      @http.should_receive(:request).with(@request).and_return(response)

      proc { ItCloudSms.send_sms(:message => "Lorem Ipsum", :destination => "+34666666666").should == true }.should_not raise_exception(ArgumentError)
    end

    it "should return error code" do
      response = Object.new
      response.stub!(:code).and_return("200")
      response.stub!(:body).and_return("-1")
      @http.should_receive(:request).with(@request).and_return(response)

      result = ItCloudSms.send_sms(:login => "foo", :password => "bar", :destination => ["+34666666660"], :message => "Lore ipsum")
      result.last[:code].should == "-1"
      result.last[:description].should == "Authentication failed"
    end

    it "should return unknown error" do
      response = Object.new
      response.stub!(:code).and_return("200")
      response.stub!(:body).and_return("Apache failure")
      @http.should_receive(:request).with(@request).and_return(response)

      result = ItCloudSms.send_sms(:login => "foo", :password => "bar", :destination => ["+34666666660"], :message => "Lore ipsum")
      result.last[:code].should == "Apache failure"
      result.last[:description].should == "Unknown error"
    end

  end

  context "when server is down" do
    it "should return raise RuntimeError when server returns an error (code != 200)" do
      proc { 
        @http = Object.new
        @http.stub!("use_ssl=").with(true)
        @http.stub!("verify_mode=").with(anything)
        @request = Object.new
        Net::HTTP.should_receive(:new).with(ItCloudSms::APIUri.host, ItCloudSms::APIUri.port).and_return(@http)
        Net::HTTP::Post.should_receive(:new).with(ItCloudSms::APIUri.request_uri).and_return(@request)
        @request.should_receive(:set_form_data).with(anything)
        response = Object.new
        response.stub!(:code).and_return("400")
        response.stub!(:body).and_return("Error")
        @http.should_receive(:request).with(@request).and_return(response)
        ItCloudSms.send_sms(:login => "foo", :password => "bar", :destination => "+34666666666", :message => "Lore ipsum").should raise_exception(RuntimeError)
      }
    end
  end

end
