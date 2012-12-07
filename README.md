# API

## GET '/'

returns 'Hello World'

## GET '/stations'

returns all the stations, like

```javascript
    [
    {
      "name": "AMPHORES 2",
        "lat": 43.5746408,
        "lon": 7.090556
    },
    {
      "name": "CASTORS",
      "lat":
        43.5997413,
      "lon":
        7.086309
    }
    ]
```

## GET '/closest?lat=somelat&lon=somelon'

returns the closest station to the somelat,somelon position. 

* If either of these input is missing, returns 500. 
* If either is 0, returns 500 (yeah, it's not correct. working on it.). 
* If somelat is outside [-90, 90], returns 500
* If somelon is outside [-180, 180], returns 500

Format of a station is the same as before.

## GET '/nextbus?station=<station_name>'

returns the schedules for that station, indexed by transportation
identification (bus line number, ...).
Ideally, there should be some magic for calculating only the next one
based on the query date, or some other field in the query.

Output :

```javascript
{
  "100":[
    {
      "terminus":"GARE ROUTIERE VALBONNE SOPHIA ANTIPOLIS",
      "schedule":"08:13"
    }
  ]
}
```

# RUN

1. Launch couchdb
2. Insert data into couchdb with `filldb-couchdb.rb`
3. (If first run) push the couchapp : `erica push "http://user:pass@localhost:5984/wtbc"`
3. Launch server : `ruby closest.rb --url "http://localhost:5984/wtbc`
4. Enjoy !

# DEPENDENCIES (gems)

* sinatra
* couchrest
* trollop
