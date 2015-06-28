require('ggmap')

createCoordinatesModel <- function(db.path=DBPATH) {
  models <- list(c("coordinates", "config/db/coordinatesTable.txt"))
  connection <- getConnection(db.path)
  createModels(connection, models)
  dbDisconnect(connection)
}


newLocations <- function(locations, db.path=DBPATH) {
  connection <- getConnection(db.path)
  ## Checking what locataions are not in db
  locations.clean <- unique(locations[locations!=""])
  res <- dbSendQuery(connection, "SELECT location FROM coordinates;")
  locationsInDb <- dbFetch(res)
  dbClearResult(res)
  dbDisconnect(connection)
  locations.clean[!(locations.clean %in% locationsInDb[,1])]
}

lookupAndAddCoordinates <- function(locations, db.path=DBPATH) {
  locations.new <- newLocations(locations, db.path=DBPATH)
  coordinates <- geocode(locations.new)  # Use amazing API to guess
  ## approximate lat/lon from textual location data.
  ## with(locations, plot(lon, lat))
  coordinates.df <- data.frame(location=locations.new, coordinates)
  connection <- getConnection(db.path)
  dbWriteTable(connection, "coordinates", coordinates.df, append=TRUE)
  dbDisconnect(connection)
  coordinates.df
}
