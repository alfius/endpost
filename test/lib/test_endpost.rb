require_relative '../test_helper'
require 'endpost'

class TestEndpost < Minitest::Test
  def setup
    Endpost.test = true
    Endpost.requester_id = 'lxxx'

    # when rebuilding the cassettes, set this two to real
    # sandbox credentials and edit the cassette manually:
    Endpost.account_id = '1234567'
    Endpost.password = 'current_password'
  end

  def test_change_pass_phrase_success
    VCR.use_cassette(:change_pass_phrase_success) do
      Endpost.change_pass_phrase('current_password', 'new_password')
    end
  end

  def test_change_pass_phrase_error
    VCR.use_cassette(:change_pass_phrase_error) do
      begin
        Endpost.change_pass_phrase('not_the_current_password', 'new_password')
      rescue => e
        assert_match /The Certified Intermediary’s pass phrase is incorrect./, e.to_s
        return
      end

      flunk
    end
  end

  def test_change_pass_phrase_connection_error
    mock_error = Minitest::Mock.new
    mock_error.expect(:call, nil) do |args|
      fail 'getaddrinfo: Temporary failure in name resolution'
    end

    begin
      RestClient.stub(:post, mock_error) do
        Endpost.change_pass_phrase('current_password', 'new_password')
      end
    rescue => e
      assert_match /getaddrinfo: Temporary failure in name resolution/, e.to_s
      return
    end

    flunk
  end

  def test_get_postage_label_success
    VCR.use_cassette(:get_postage_label_success) do
      response = Endpost.get_postage_label({
        :from => {
          :full_name => 'Alf Test',
          :address => '10B Glenlake Parkway, Suite 300',
          :city => 'Atlanta',
          :state => 'CA',
          :zip => '30328',
        },
        :to => {
          :full_name => 'Harry Whitehouse',
          :address => '247 High Street',
          :city => 'Palo Alto',
          :state => 'CA',
          :zip => '94301',
        },
        :weight => 16,
        :mail_class => 'Priority',
        :mailpiece_shape => 'Parcel',
        :sort_type => 'SinglePiece',
      })

      refute_empty Base64.decode64(response)
    end
  end

  def test_get_postage_label_error
    VCR.use_cassette(:get_postage_label_error) do
      begin
        response = Endpost.get_postage_label({
          :from => {
            :zip => '30328',
          },
          :to => {
            :zip => '94301',
          },
          :weight => 16,
          :mail_class => 'Priority',
          :mailpiece_shape => 'Parcel',
          :sort_type => 'SinglePiece',
        })
      rescue => e
        assert_match /Missing or invalid element/, e.to_s
        return
      end
    end

    flunk
  end

  def test_get_postage_label_connection_error
    mock_error = Minitest::Mock.new
    mock_error.expect(:call, nil) do |args|
      fail 'getaddrinfo: Temporary failure in name resolution'
    end

    begin
      RestClient.stub(:post, mock_error) do
        response = Endpost.get_postage_label({
          :from => {
          },
          :to => {
          },
        })
      end
    rescue => e
      assert_match /getaddrinfo: Temporary failure in name resolution/, e.to_s
      return
    end

    flunk
  end

  def test_buy_postage_success
    VCR.use_cassette(:buy_postage_success) do
      Endpost.buy_postage(10)
    end
  end

  def test_buy_postage_error
    VCR.use_cassette(:buy_postage_error) do
      begin
        Endpost.buy_postage(5)
      rescue => e
        assert_match /The purchase amount is too low/, e.to_s
        return
      end

      flunk
    end
  end

  def test_buy_postage_connection_error
    mock_error = Minitest::Mock.new
    mock_error.expect(:call, nil) do |args|
      fail 'getaddrinfo: Temporary failure in name resolution'
    end

    begin
      RestClient.stub(:post, mock_error) do
        Endpost.buy_postage(10)
      end
    rescue => e
      assert_match /getaddrinfo: Temporary failure in name resolution/, e.to_s
      return
    end

    flunk
  end
end
