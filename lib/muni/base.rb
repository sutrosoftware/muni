require "ostruct"

module Muni
  class NextBusError < StandardError; end
  class Base < OpenStruct
    class << self
      private

      def fetch(command, options = {})
        url = build_url(command, options)
        xml = Net::HTTP.get(URI.parse(url))
        doc = XmlSimple.xml_in(xml, {'ForceArray' => false}) || {}
        fail NextBusError, doc['Error'].first['content'].gsub(/\n/,'') if doc['Error']
        doc
      end

      def build_url(command, options = {})
        url = "https://api.511.org/transit/#{command}?operator_id=SF&agency=SF&format=xml"
        options.each { |key,value| url << "&#{key}=#{value}" }
        # puts "fetching: #{url}"
        url
      end

    end
  end
end
