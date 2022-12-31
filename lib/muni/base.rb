require "ostruct"

module Muni
  class NextBusError < StandardError; end
  class Base < OpenStruct
    class << self
      private

      def fetch(command, options = {})
        url = build_url(command, options)
        json = Net::HTTP.get(URI.parse(url))
        doc = JSON.parse(json) || {}
        doc
      end

      def build_url(command, options = {})
        url = "https://webservices.umoiq.com/api/pub/v1/agencies/sfmta-cis/#{command}?key=#{APIKEY}"
        options.each { |key,value| url << "&#{key}=#{value}" }
#        puts "fetching: #{url}"
        url
      end

    end
  end
end
