require 'base64'
require 'restclient'
require 'nokogiri'

class Endpost
  BASE_URL = 'https://elstestserver.endicia.com/LabelService/EwsLabelService.asmx'

  class << self
    attr_accessor :test, :requester_id, :account_id, :password

    def change_pass_phrase(old_password, new_password)
      xml = %!
        <ChangePassPhraseRequest>
          <RequesterID>#{requester_id}</RequesterID>
          <RequestID>0</RequestID>
          <CertifiedIntermediary>
            <AccountID>#{account_id}</AccountID>
            <PassPhrase>#{old_password}</PassPhrase>
          </CertifiedIntermediary>
          <NewPassPhrase>#{new_password}</NewPassPhrase>
        </ChangePassPhraseRequest>!

      response = RestClient.post "#{BASE_URL}/ChangePassPhraseXML", :changePassPhraseRequestXML => xml

      response_xml = Nokogiri::XML(response.body)
      status_node_xml = response_xml.css('ChangePassPhraseRequestResponse Status').first
      endicia_response_code = status_node_xml ? status_node_xml.text : nil

      unless endicia_response_code == '0'
        error_message_node_xml = response_xml.css('ChangePassPhraseRequestResponse ErrorMessage').first
        endicia_response_message = error_message_node_xml ? error_message_node_xml.text : 'Unknown error'
        fail endicia_response_message
      end
    end

    def get_postage_label(args)
      xml = %!
        <LabelRequest Test="#{test ? 'YES' : 'NO'}" LabelType="Default" ImageFormat="PDF" LabelSize="4x6">
          <RequesterID>#{requester_id}</RequesterID>
          <AccountID>#{account_id}</AccountID>
          <PassPhrase>#{password}</PassPhrase>
          <MailClass>#{args[:mail_class]}</MailClass>
          <MailpieceShape>#{args[:mailpiece_shape]}</MailpieceShape>
          <SortType>#{args[:sort_type]}</SortType>
          <DateAdvance>0</DateAdvance>
          <WeightOz>#{args[:weight]}</WeightOz>
          <Services DeliveryConfirmation="ON" SignatureConfirmation="OFF"/>
          <ReferenceID>#{args[:order_number]}</ReferenceID>
          <PartnerCustomerID>1</PartnerCustomerID>
          <PartnerTransactionID>1</PartnerTransactionID>
          <ToName>#{args[:to][:full_name]}</ToName>
          <ToCompany>#{args[:to][:company]}</ToCompany>
          <ToAddress1>#{args[:to][:address]}</ToAddress1>
          <ToCity>#{args[:to][:city]}</ToCity>
          <ToState>#{args[:to][:state]}</ToState>
          <ToPostalCode>#{args[:to][:zip]}</ToPostalCode>
          <ToPhone>#{args[:to][:phone]}</ToPhone>
          <FromName>#{args[:from][:full_name]}</FromName>
          <ReturnAddress1>#{args[:from][:address]}</ReturnAddress1>
          <FromCity>#{args[:from][:city]}</FromCity>
          <FromState>#{args[:from][:state]}</FromState>
          <FromPostalCode>#{args[:from][:zip]}</FromPostalCode>
        </LabelRequest>!

      begin
        response = RestClient.post "#{BASE_URL}/GetPostageLabelXML", :labelRequestXML => xml

        response_xml = Nokogiri::XML(response.body)
        status_node_xml = response_xml.css('LabelRequestResponse Status').first
        endicia_response_code = status_node_xml ? status_node_xml.text : nil

        unless endicia_response_code == '0'
          error_message_node_xml = response_xml.css('LabelRequestResponse ErrorMessage').first
          endicia_response_message = error_message_node_xml ? error_message_node_xml.text : 'Unknown error'
          fail endicia_response_message
        end

        label_node_xml = response_xml.css('LabelRequestResponse Base64LabelImage').first
        return label_node_xml.text

      rescue => e
        fail e.to_s
      end
    end

    def buy_postage(amount)
      xml = %!
      <RecreditRequest>
        <RequesterID>#{requester_id}</RequesterID>
        <RequestID>0</RequestID>
        <CertifiedIntermediary>
          <AccountID>#{account_id}</AccountID>
          <PassPhrase>#{password}</PassPhrase>
        </CertifiedIntermediary>
        <RecreditAmount>#{amount}</RecreditAmount>
      </RecreditRequest>!

      begin
        response = RestClient.post "#{BASE_URL}/BuyPostageXML", :recreditRequestXML => xml

        response_xml = Nokogiri::XML(response.body)
        status_node_xml = response_xml.css('RecreditRequestResponse Status').first
        endicia_response_code = status_node_xml ? status_node_xml.text : nil

        unless endicia_response_code == '0'
          error_message_node_xml = response_xml.css('RecreditRequestResponse ErrorMessage').first
          endicia_response_message = error_message_node_xml ? error_message_node_xml.text : 'Unknown error'
          fail endicia_response_message
        end

      rescue => e
        fail e.to_s
      end
    end
  end
end
