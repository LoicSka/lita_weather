
require 'open-uri'
require 'json'

module Lita
  module Handlers
    class Weather < Handler

      def populate_week
        dates = Hash.new
        today = Date.today
        dates["today"] = today.strftime("%Y/%m/%d")
        dates["tonight"] = today.strftime("%Y/%m/%d")
        dates["tomorow"] = (today + 1).strftime("%Y/%m/%d")
        dates["yesterday"] = (today - 1).strftime("%Y/%m/%d")

        direction = "->"
        current_day = today

        7.times do |i|
          if direction == "->"
            direction = current_day.strftime("%A") == "Sunday" ? "<-" : "->"
            next_day = (current_day + 1)
            dates[next_day.strftime("%A").downcase] = next_day.strftime("%Y/%m/%d") unless current_day.strftime("%A") == "Sunday"
            current_day = current_day.strftime("%A") == "Sunday" ? today : next_day
          else
            direction = current_day.strftime("%A") == "Monday" ? "->" : "<-"
            next_day = (current_day - 1)
            dates[next_day.strftime("%A").downcase] = next_day.strftime("%Y/%m/%d")
            current_day = next_day
          end

        end
        return dates
      end

      route(
        /wheather\s((?:\S+\s+){1}\S+).*/i,
        :wheather,
        :command => true,
        :help => {
          "weather forecast for specific period" => "Will provide you wheather forecst for desired "
        }
      )

      def wheather(response)
        obj = response.matches.first[0].split(" ")
        stat = obj[0]
        date = obj[1]
        week = populate_week

        body = get_forecast_for_date(date)
        response.reply(body)

      end

      def get_forecast_for_date(date)
        open('http://api.wunderground.com/api/daf4bfd37ff44947/forecast/q/CA/San_Francisco.json') do |f|
          json_string = f.read
          parsed_json = JSON.parse(json_string)
          # location = parsed_json['location']['city']
          # temp_f = parsed_json['current_observation']['temp_f']
          return "#{json_string}\n"
        end
      end

      Lita.register_handler(self)
    end
  end
end
