#!/usr/bin/env ruby -wKU

STATIONS = []
ROUTES = []

def display_schedule
  max_length = 0
  STATIONS.each do |station|
    station_name = station.split.drop(2).join(" ") # drop lat and lon
    max_length = station_name.size if station_name.size > max_length
  end

  ROUTES.each do |route|
    schedule = route.split
    puts "ERROR" if schedule.size != STATIONS.size
    STATIONS.zip(schedule).each do |tuple|
      station_name = tuple.first.split.drop(2).join(" ") # drop lat and lon
      printf "%-#{max_length}s\t%s\n", station_name, tuple.last
    end
  end
end

state = :stations

File.open("100.schedule").each do |line|
  if line == "\n"
    state = :schedule
    next
  end


  if state == :stations
    STATIONS << line.strip
  elsif state == :schedule
    ROUTES << line
  end

  display_schedule
end

