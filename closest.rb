require 'sinatra/base'

STATIONS = []

File.open("100.schedule").each do |line|
  if line == "\n"
    break
  end
  lat, lon, *name = line.strip.split
  STATIONS << {:lat => lat.to_f, :lon => lon.to_f, :name => name.join(" ")}
end

class WTBC < Sinatra::Base
  get '/' do
    'Hello world!'
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

