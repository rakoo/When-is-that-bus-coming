#!/usr/bin/env ruby -KU

require 'couchrest'

COUCH = CouchRest.database "http://localhost:5984/wtbc"
STATIONS = []
SCHEDULES = []

FILENAME = "100.schedule"

def upload_to_couch
  line_number = FILENAME.split(".").first
  stations_docs = STATIONS.map do |station|
    station.merge({
      :type => :station,
      :lines => [line_number]
    })
  end
  COUCH.bulk_save(stations_docs, {:all_or_nothing => true})

  schedule_doc = {
    :type => :schedule,
    :line_number => line_number,
    :stations => STATIONS.map {|station| station[:name]},
    :schedules => SCHEDULES
  }
  COUCH.save_doc schedule_doc
     
end

state = :stations

File.open(FILENAME).each do |line|
  if line == "\n"
    state = :schedule
    next
  end


  if state == :stations
    lat, lon, *name = line.strip.split
    name = name.join " "
    STATIONS << {:name => name, :lat => lat, :lon => lon}
  elsif state == :schedule
    SCHEDULES << line.split
  end

  upload_to_couch
end

