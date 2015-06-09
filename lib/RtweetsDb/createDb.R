require('DBI')
require("RSQLite")

getConnection <- function(dbFileName) {
  if (!file.exists('db')) dir.create('db')
  dbConnect(SQLite(), dbFileName) 
}

createTable <- function(connection, tableName, schema) {
  if (!dbExistsTable(connection, tableName)) {
    query <- paste0(
      "CREATE TABLE ",tableName,  " (", schema, ");")
    dbSendQuery(connection, query)
  }
}

createTableFromFile <- function(connection, tableName, schemaFileName) {
  schema <- readChar(schemaFileName, file.info(schemaFileName)$size)
  createTable(connection, tableName, schema)
}


