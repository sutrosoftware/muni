require 'muni/base'
require 'muni/prediction'
require 'time'

module Muni
  class Stop < Base
    def predictions
      retval = []
      stop = Stop.send(:fetch, "stopcodes/#{tag}/predictions")
      # filter below list by stop object properties route & direction
      stop.each do |pred|
        line = pred['route']['id']
        if line == route_tag
          pred['values'].each do |arrival|
            dir = "inbound"
            dirstr = arrival['direction']['id']
            if dirstr["_0_"]
              dir = "outbound"
            end
            if dir == direction
              etime = arrival['timestamp'] / 1000
              retval.push(Prediction.new({:epochTime => etime}))
            end
          end
        end
      end
      retval
    end
  end
end
