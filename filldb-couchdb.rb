#!/usr/bin/env ruby -KU

require 'couchrest'
require 'trollop'

abort("No couchdb url; quitting.") unless ARGV[0]
COUCH = CouchRest.database ARGV[0]
STATIONS = []
SCHEDULES = []

FILENAME = ARGV[1]
abort("No data file; quitting.") unless FILENAME


state = :stations

# Fill the arrays ...
COUCH.delete!
COUCH.create!
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

end

# ... and feed them to couch
line = File.basename(FILENAME).split(".").first
stations_docs = STATIONS.map do |station|
  station.merge({
    :type => :station,
    :lines => [line]
  })
end
COUCH.bulk_save(stations_docs, {:all_or_nothing => true})

schedule_doc = {
  :type => :schedule,
  :line => line,
  :stations => STATIONS.map {|station| station[:name]},
  :schedules => SCHEDULES
}
COUCH.save_doc schedule_doc

