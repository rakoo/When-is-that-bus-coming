function(doc, req) {
  if (doc) {
    if (doc.type == 'schedule') {
      for (stationIndex = 0; stationIndex < doc.stations.length; stationIndex++) {
        station = doc.stations[stationIndex];
        send(station.lat + "\t" + station.lon + "\t" + station.name + "\n");
      }
      send("\n");

      for (scheduleIndex = 0; scheduleIndex < doc.schedules.length; scheduleIndex++) {
        schedule = doc.schedules[scheduleIndex];
        for (scheduleAtStationIndex = 0; scheduleAtStationIndex < schedule.length; scheduleAtStationIndex++) {
          send(schedule[scheduleAtStationIndex]);
          if (scheduleAtStationIndex != schedule.length - 1) {
            send("\t");
          }
        }
        send("\n");
      }
    }
  }
}
