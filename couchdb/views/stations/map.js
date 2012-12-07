function(doc) {
  if (doc.type == 'schedule') {
    for (stationIndex = 0; stationIndex < doc.stations.length; stationIndex++) {
      station = doc.stations[stationIndex];
      emit(station["name"], {"lat" : station["lat"], "lon" : station["lon"]});
    }
  }
}
