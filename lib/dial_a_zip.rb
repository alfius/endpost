module DialAZip
  DIAL_A_ZIP_BASE_URL = 'http://www.dial-a-zip.com/XML-Dial-A-ZIP/DAZService.asmx'

  DIAL_A_ZIP_RESPONSE_MESSAGES = {
    '10' => 'More than one delivery address was detected',
    '11' => 'ZIP Code could not be found',
    '12' => 'The State code is invalid',
    '13' => 'The City is invalid',
    '21' => 'The address as submitted could not be found',
    '22' => 'More than one ZIP code was found',
    '25' => 'The Street address is invalid',
    '31' => 'Exact Match',
    '32' => 'More information, such as an apartment or suite number, may give a more specific address.',
  }

  attr_accessor :dial_a_zip_user, :dial_a_zip_password

  def verify_address(address)
    xml = %!
    <VERIFYADDRESS>
      <COMMAND>ZIP1</COMMAND>
      <SERIALNO>#{dial_a_zip_user}</SERIALNO>
      <USER>#{dial_a_zip_user}</USER>
      <PASSWORD>#{dial_a_zip_password}</PASSWORD>
      <ADDRESS0></ADDRESS0>
      <ADDRESS1>#{address[:full_name]}</ADDRESS1>
      <ADDRESS2>#{address[:address]}</ADDRESS2>
      <ADDRESS3>#{address[:city]}, #{address[:state]} #{address[:zipcode]}</ADDRESS3>
    </VERIFYADDRESS>!

    begin
      response = RestClient.post "#{DIAL_A_ZIP_BASE_URL}/MethodZIPValidate", :input => xml

      response_xml = Nokogiri::XML(response.body)

      return_code_node_xml = response_xml.css('Dial-A-ZIP_Response ReturnCode').first
      return_code = return_code_node_xml ? return_code_node_xml.text : nil

      addr_exists_node_xml = response_xml.css('Dial-A-ZIP_Response AddrExists').first
      addr_exists = addr_exists_node_xml ? addr_exists_node_xml.text : nil

      if return_code == '31' && addr_exists == 'TRUE'
        return {
          :full_name => response_xml.css('Dial-A-ZIP_Response AddrLine2').first.text,
          :address => response_xml.css('Dial-A-ZIP_Response AddrLine1').first.text,
          :city => response_xml.css('Dial-A-ZIP_Response City').first.text,
          :state => response_xml.css('Dial-A-ZIP_Response State').first.text,
          :zip => [response_xml.css('Dial-A-ZIP_Response ZIP5').first.text, response_xml.css('Dial-A-ZIP_Response Plus4').first.text].join('-'),
        }
      else
        fail DIAL_A_ZIP_RESPONSE_MESSAGES[return_code]
      end

    rescue => e
      fail e.to_s
    end
  end
end
