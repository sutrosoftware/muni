require 'net/http'
require 'json'

require 'muni/stop'
require 'muni/direction'

module Muni
  class Route < Base
    def direction_at(direction)
      return send(direction.downcase.to_sym) if direction =~ /(outbound|inbound)/i
      directions.select { |dir| dir.id == direction }.first
    end

    def outbound
      directions.select { |dir| dir.name =~ /ob/i }.first
    end

    def inbound
      directions.select { |dir| dir.name =~ /ib/i }.first
    end

    class << self
      def find(tag)
        if tag == :all
          find_all
        else
          find_by_tag(tag)
        end
      end

      private
        def find_all
          document = fetch(:routes)
          document.collect do |el|
            Route.new({ :tag => el['id'], :title => el['title'] })
          end
        end

        def find_by_tag(tag)
          document = fetch("routes/#{tag}")
          route = Route.new({ :tag => document['id'], :title => document['title'] })
          route.directions = []
          ibstops = []
          obstops = []

          document['stops'].each do |stop|
            dir = "inbound"
            dirstr = stop['directions'][0]
            if dirstr["_0_"]
              dir = "outbound"
            end
            st = Stop.new({
                            :tag => stop['code'],
                            :title => stop['name'],
                            :lat => stop['lat'],
                            :lon => stop['lon'],
                            :stopId => stop['code'],
                            :route_tag => tag,
                            :direction => dir
                          })
            if dir == 'inbound'
              ibstops << st
            else
              obstops << st
            end
          end
          route.directions << Direction.new({ :id => 'inbound', :name => 'IB', :stops => ibstops })
          route.directions << Direction.new({ :id => 'outbound', :name => 'OB', :stops => obstops })
          route
        end
    end
  end
end
