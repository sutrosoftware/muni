require 'muni/base'
require 'muni/prediction'

module Muni
  class Stop < Base
    def predictions
      stop = Stop.send(:fetch, :StopMonitoring, stopcode: tag, api_key: api_key)
      stop['ServiceDelivery']['StopMonitoringDelivery']['MonitoredStopVisit'].each do |pred|
        puts pred['MonitoredVehicleJourney']['LineRef']
        puts pred['MonitoredVehicleJourney']['PublishedLineName'].titleize
        puts pred['MonitoredVehicleJourney']['DirectionRef']
        puts pred['MonitoredVehicleJourney']['MonitoredCall']['ExpectedArrivalTime']
      end
      #      available_predictions(stop).collect do |pred|
      #  Prediction.new(pred)
      #end
    end

    private

    def available_predictions(stop)
      return [] unless  stop &&
                        stop['predictions'] && 
                        stop['predictions'].first['direction'] &&
                        stop['predictions'].first['direction'].first['prediction']
                        
      stop['predictions'].first['direction'].first['prediction']
    end

  end
end
