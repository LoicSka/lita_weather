
require 'open-uri'
require 'json'
require 'ostruct'

class String
  def underscore
    self.gsub(/::/, '/').
    gsub(/ /, '_').
    gsub(/'/, '_').
    gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
    gsub(/([a-z\d])([A-Z])/,'\1_\2').
    gsub(/\(/, '').
    gsub(/\)/, '').
    tr("-", "_").
    downcase
  end
end

module Lita
  module Handlers
    class Weather < Handler

      config :api_key, type: String,
                       required: true
      config :default_city, type: String,
                       required: true

      DAYS = %w(
        MONDAY
        TUESDAY
        WEDNESDAY
        THURSDAY
        FRIDAY
        SATURDAY
        SUNDAY
      )

      route(
        /weather\s((?:\S+\s+){0,}\S+).*/i,
        :weather,
        :command => true,
        :help => {
          "weather forecast for specific period" => "Will provide you wheather forecst for desired "
        }
      )

      def find_city(name)
        file = File.read('cities.json')
        cities = JSON.parse(file)
        cities[name].nil? ? nil : OpenStruct.new(cities[name])
      end

      def weather(response)
        obj = response.matches.first[0].split(" ")
        days = obj.select{|day| DAYS.include?(day.upcase)}
        city = obj.index("in").nil? ? find_city(Lita.config.handlers.weather.default_city.downcase.underscore) : find_city(obj.drop(obj.index("in") + 1).join("_").downcase.underscore)
        unless city.nil?
          week = get_forecast_for_week(city)
          day = days.empty? ? Time.now.strftime("%A").downcase : days.first.downcase
          forecast = week[day].nil? ? "Sorry I was unable to fetch the forecast." : week[day]
          response.reply(forecast)
        else
          response.reply("Please provide a valid city name.")
        end
      end

      # gets 10 day forecast  
      def get_forecast_for_week(city)
        week = Hash.new
        open("http://api.wunderground.com/api/#{Lita.config.handlers.weather.api_key}/forecast10day/q/#{city.region}/#{city.name}.json") do |f|
          json_string = f.read
          parsed_json = JSON.parse(json_string)
          periods = parsed_json['forecast']['txt_forecast']['forecastday']
          periods.each {|period| week[period["title"].downcase] = period["fcttext_metric"]}
        end
        return week
      end

      Lita.register_handler(self)
    end
  end
end

