require 'net/http'
require 'xmlsimple'

require 'muni/stop'
require 'muni/direction'

module Muni
  class Route < Base
    def direction_at(direction)
      return send(direction.downcase.to_sym) if direction =~ /(outbound|inbound)/i
      directions.select{|dir| dir.id == direction}.first
    end

    def outbound
      directions.select{ |dir| dir.name =~ /outbound/i }.first
    end

    def inbound
      directions.select{ |dir| dir.name =~ /inbound/i }.first
    end

    class << self
      def find(tag, options = {})
        if tag == :all
          find_all(options)
        else
          find_by_tag(tag, options)
        end
      end

      private
        def find_all(options = {})
          document = fetch(:lines, options)
          document['ServiceDelivery']['DataObjectDelivery']['dataObjects']['ServiceFrame']['lines']['Line'].collect do |el|
            Route.new({:tag => el['id'], :title => el['Name'].titleize})
          end
        end

        def find_by_tag(tag, options = {})
          document = fetch(:lines, options.merge({:line_id => tag}))
          el = document['ServiceDelivery']['DataObjectDelivery']['dataObjects']['ServiceFrame']['lines']['Line']
          route = Route.new({:tag => el['id'], :title => el['Name']})

=begin
          stops = {}

          document['route'].first['stop'].each do |stop|
            st = Stop.new({
              :tag => stop['tag'],
              :title => stop['title'],
              :lat => stop['lat'],
              :lon => stop['lon'],
              :stopId => stop['lat'],
            })
            stops[st.tag] = st
          end

          directions = []
          route.directions = document['route'].first['direction'].collect do |direction|
            direction_stops = direction['stop'].collect do |stop|
              stops[stop['tag']]
            end

            direction_stops.each do |stop|
              stop.route_tag = route.tag
              stop.direction = direction['tag']
            end

            Direction.new({
                :id => direction['tag'],
                :name => direction['title'],
                :stops => direction_stops
            })
          end
=end

          route
        end
    end
  end
end
