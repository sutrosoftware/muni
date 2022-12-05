require 'net/http'
require 'xmlsimple'

require 'muni/stop'
require 'muni/direction'

module Muni
  class Route < Base
    def direction_at(direction)
      return send(direction.downcase.to_sym) if direction =~ /(outbound|inbound)/i
      directions.select { |dir| dir.id == direction }.first
    end

    def outbound
      directions.select { |dir| dir.name =~ /outbound/i }.first
    end

    def inbound
      directions.select { |dir| dir.name =~ /inbound/i }.first
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
          Route.new({ :tag => el['id'], :title => el['Name'].titleize })
        end
      end

      def find_by_tag(tag, options = {})
        document = fetch(:lines, options.update({ :line_id => tag }))
        el = document['ServiceDelivery']['DataObjectDelivery']['dataObjects']['ServiceFrame']['lines']['Line']
        route = Route.new({ :tag => el['id'], :title => el['Name'].titleize })
        route.directions = []
        ibstops = []
        obstops = []

        # Inbound
        document = fetch(:stops, options.merge({ :direction_id => 'IB' }))
        document['ServiceDelivery']['DataObjectDelivery']['dataObjects']['ServiceFrame']['scheduledStopPoints']['ScheduledStopPoint'].each do |stop|
          st = Stop.new({
                          :tag => stop['id'],
                          :title => stop['Name'],
                          :lat => stop['Location']['Latitude'],
                          :lon => stop['Location']['Longitude'],
                          :stopId => stop['id'],
                          :route_tag => '43',
                          :direction => 'IB'
                        })
          ibstops << st
        end
        route.directions << Direction.new({ :id => 'IB', :name => 'Inbound', :stops => ibstops })

        # Outbound
        document = fetch(:stops, options.merge({ :direction_id => 'OB' }))
        document['ServiceDelivery']['DataObjectDelivery']['dataObjects']['ServiceFrame']['scheduledStopPoints']['ScheduledStopPoint'].each do |stop|
          st = Stop.new({
                          :tag => stop['id'],
                          :title => stop['Name'],
                          :lat => stop['Location']['Latitude'],
                          :lon => stop['Location']['Longitude'],
                          :stopId => stop['id'],
                          :route_tag => '43',
                          :direction => 'OB'
                        })
          obstops << st
        end
        route.directions << Direction.new({ :id => 'OB', :name => 'Outbound', :stops => obstops })

        route
      end
    end
  end
end
