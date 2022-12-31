require 'muni/base'
require 'muni/route'
require 'muni/version'
require 'dotenv/load'

module Muni
  APIKEY = ENV['APIKEY'] || "1234567890"
  PREDTTL = 30
  ROUTETTL = 60 * 60
end
