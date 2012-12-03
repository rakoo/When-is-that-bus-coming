#!/usr/bin/env ruby -wKU

require 'redis'

REDIS = Redis.new

state = :stations

File.open("100.schedule").each do |line|
  if line == "\n"
    state = :schedule
    next
  end


  if state == :stations
    lat, lon, *name = line.strip.split
    name = name.join " "
    p name
    REDIS.hset "STATION:#{name}", "lat", lat
    REDIS.hset "STATION:#{name}", "lon", lon

    REDIS.sadd "#{name}:LINES", "100"

  elsif state == :schedule
    REDIS.sadd "LINE:100", line
    REDIS.sadd "LINES", "100"
  end

end

