require 'base64'
require 'restclient'
require 'nokogiri'

require_relative './label_server.rb'
require_relative './dial_a_zip.rb'

class Endpost
  extend LabelServer
  extend DialAZip
end
