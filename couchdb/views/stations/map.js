function(doc) {
  if (doc.type == 'station') {
    emit(doc.name, {"lat" : doc.lat, "lon" : doc.lon});
  }
}
