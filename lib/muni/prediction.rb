require 'action_view'

module Muni
  class Prediction < Base
    include ActionView::Helpers::DateHelper
    def time
      Time.at(epochTime)
    end

    def pretty_time
      if time > Time.now
        distance_of_time_in_words_to_now(time)
      elsif time < Time.now
        time_ago_in_words(time)
      else
        "Arriving"
      end
    end
  end
end