require 'muni/base'
require 'muni/prediction'
require 'time'

module Muni
  class Stop < Base
    def predictions
      retval = []
      stop = Stop.send(:fetch, :StopMonitoring, stopcode: tag, api_key: api_key)
      # filter below list by stop object properties route & direction
      stop['ServiceDelivery']['StopMonitoringDelivery']['MonitoredStopVisit'].each do |pred|
        #        pred['MonitoredVehicleJourney']['PublishedLineName'].titleize
        line = pred['MonitoredVehicleJourney']['LineRef']
        dir = pred['MonitoredVehicleJourney']['DirectionRef']
        if line == route_tag && dir == direction
          artime = pred['MonitoredVehicleJourney']['MonitoredCall']['ExpectedArrivalTime']
          etime = Time.parse(artime).to_i
          retval.push(Prediction.new({:epochTime => etime}))
        end
      end
      retval
    end
  end
end
