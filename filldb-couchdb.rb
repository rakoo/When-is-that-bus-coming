#!/usr/bin/env ruby -KU

require 'couchrest'
require 'trollop'

abort("No couchdb url; quitting.") unless ARGV[0]
COUCH = CouchRest.database ARGV[0]

DIRNAME = ARGV[1]
abort("No data dir; quitting.") unless DIRNAME
abort("#{DIRNAME} is not a dir") unless File.directory?(DIRNAME)



# Fill the arrays ...
COUCH.delete!
COUCH.create!
Dir.foreach(DIRNAME) do |entry|
  file = File.absolute_path(entry, DIRNAME)
  next unless (File.file?(file) and File.extname(file) == ".schedule")

  stations = []
  schedules = []

  state = :stations
  File.open(file).each do |line|
    if line == "\n"
      state = :schedule
      next
    end


    if state == :stations
      splitted = line.strip.split
      lat, lon, name = if splitted[0].to_f != 0 && splitted[1].to_f != 0
                         [splitted[0].to_f, splitted[1].to_f, splitted.drop(2).join(" ")]
                       else
                         [0, 0, splitted.join(" ")]
                       end
      stations << {:name => name, :lat => lat, :lon => lon}
    elsif state == :schedule
      schedules << line.split
    end

  end

  # ... and feed them to couch

  schedule_doc = {
    :type => :schedule,
    :line => File.basename(file).split(".").first,
    :stations => stations,
    :schedules => schedules
  }

  COUCH.save_doc schedule_doc
end
