require 'sinatra/base'

require 'couchrest'
require 'trollop'
require 'json'
require 'cgi'

STATIONS = []

def load_stations
  STATIONS.clear
  COUCH.view('extract/stations')["rows"].each do |row|
    STATIONS << {:name => row["key"], :lat => row["value"]["lat"].to_f, :lon => row["value"]["lon"].to_f}
  end
end



opts = Trollop::options do
  opt :url, "URL of Couchdb database", :required => true, :type => :string
end

COUCH = CouchRest.database opts[:url]
load_stations

class WTBC < Sinatra::Base
  get '/ui' do
    File.read('ui.html')
  end

  get '/stations' do
    content_type :json

    STATIONS.to_json
  end

  get '/closest' do
    content_type :json

    lat, lon = params[:lat], params[:lon]
    return 404 unless (lat and lon)

    lat = lat.to_f
    lon = lon.to_f

    return 500 if lat == 0 and lon == 0 # TODO : what if the user is here ?
    return 500 if lat < -90 or lat > 90 or lon < -180 or lon > 180

    closest_station(lat, lon).to_json
  end

  get '/nextbus' do
    content_type :json

    station_name = CGI.unescape(params[:station_name])
    resultsByLine = {}
    COUCH.view('extract/schedulesByStation', {:key => station_name})["rows"].each do |row|
      resultsByLine[row["value"]["line"]] ||= []
      resultsByLine[row["value"]["line"]] << {:terminus => row["value"]["terminus"], :schedule => row["value"]["schedule"]}
    end

    resultsByLine.to_json
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

    closest
  end

  run! if app_file == $0
end

