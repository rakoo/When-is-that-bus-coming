require 'sinatra/base'

require 'redis'

REDIS = Redis.new
STATIONS = []

def load_stations
  STATIONS.clear
  REDIS.keys("STATION:*").each do |station|
    station_hash = REDIS.hgetall station
    STATIONS << {:lat => station_hash["lat"].to_f, :lon => station_hash["lon"].to_f, :name => station.gsub(/STATIONS:\*/, "")}
  end
  puts "Loaded #{STATIONS.size} stations"
end

load_stations

class WTBC < Sinatra::Base
  get '/' do
    'Hello world!'
  end

  get '/reload' do
    load_stations
  end

  get '/stations' do
    STATIONS.map do |station|
      "#{station[:name]}\n\t#{station[:lat]}\t#{station[:lon]}\n\t------\n"
    end
  end

  get '/closest' do
    lat, lon = params[:lat], params[:lon]
    return 404 unless (lat and lon)

    lat = lat.to_f
    lon = lon.to_f

    return 500 if lat == 0 and lon == 0 # TODO : what if the user is here ?
    return 500 if lat < -90 or lat > 90 or lon < -180 or lon > 180

    closest_station lat, lon
  end


  def closest_station lat, lon
    scale_factor = Math.cos(lat)
    # Use the Manhattan distance, because we only want the closest one
    min_dist = Float::MAX
    closest = nil
    STATIONS.each do |station|
      dist = scale_factor * (lat - station[:lat]).abs + (lon - station[:lon]).abs
      if min_dist > dist
        min_dist = dist
        closest = station
      end
    end

    closest[:name]
  end

  run! if app_file == $0
end

