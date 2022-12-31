require 'ostruct'
require 'zache'

module Muni
  class NextBusError < StandardError; end
  class Base < OpenStruct
    @@zache = Zache.new
    class << self
      private

      def fetch(command, options = {})
        url = build_url(command, options)
        ttl = ROUTETTL
        if url.include? "pred"
          ttl = PREDTTL
        end
        doc = @@zache.get(url.to_sym, lifetime: ttl) {
          #          File.write("/tmp/muni.log", "fetching #{url}\n", mode: 'a')
          puts "fetching #{url}"
          json = Net::HTTP.get(URI.parse(url))
          JSON.parse(json) || {}
        }
        doc
      end

      def build_url(command, options = {})
        url = "https://webservices.umoiq.com/api/pub/v1/agencies/sfmta-cis/#{command}?key=#{APIKEY}"
        options.each { |key,value| url << "&#{key}=#{value}" }
        url
      end

    end
  end
end
