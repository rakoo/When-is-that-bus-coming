function(doc) {
  if (doc.type == 'schedule') {
    for (scheduleIndex = 0; scheduleIndex < doc.schedules.length; scheduleIndex++) {
      schedule = doc.schedules[scheduleIndex];
      for (stationIndex = 0; stationIndex < doc.stations.length; stationIndex++) {
        station = doc.stations[stationIndex];
        if (schedule[stationIndex] == 'NULL') {
          continue;
        }
        value = {
          "line" : doc.line,
          "terminus" : doc.stations[doc.stations.length - 1],
          "schedule" : schedule[stationIndex]
        };
        emit(station["name"], value);
      }
    }
  }

}
