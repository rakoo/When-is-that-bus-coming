#!/usr/bin/env ruby -wKU

STATIONS = []
ROUTES = []

def display_schedule
  max_length = 0
  STATIONS.each do |station|
    max_length = station.size if station.size > max_length
  end

  ROUTES.each do |route|
    schedule = route.split
    puts "ERROR" if schedule.size != STATIONS.size
    STATIONS.zip(schedule).each do |tuple|
      printf "%-#{max_length}s\t%s\n", tuple.first, tuple.last
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

