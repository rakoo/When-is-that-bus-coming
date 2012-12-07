#!/usr/bin/env ruby -KU

require 'nokogiri'

html = Nokogiri::HTML(File.new("html"))
line = html.css('li.line .important .icon').first.attributes["alt"].value
company = html.css('li.reseau .icon').first.attributes["alt"].value.upcase

rows = html.css('table#linehour tbody tr[class]')
stations = rows.map do |row|
  station = row.css('td a[href]').first
  if station
    name = station.children.text
    name unless name.nil? or name == ""
  end
end

parsed_schedules = []
rows.each do |row|
  schedules_for_station = row.css('td.horaire')
  schedules_for_station.to_a.each_index do |i|
    parsed_schedules[i] ||= []

    schedule = schedules_for_station.children[i].text
    parsed_schedules[i] << (schedule == "|" ? "NULL" : schedule)
  end
end

File.open("#{company}:#{line}.schedule", File::TRUNC|File::WRONLY|File::CREAT) do |file|
  file.puts stations.join("\n")
  file.puts
  parsed_schedules.each do |schedule|
    p schedule.join("\t")
    file.puts schedule.join("\t")
  end
end
