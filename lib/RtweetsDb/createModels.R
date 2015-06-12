createModels <- function(connection, models) {
  lapply(models, function(model) {
    createTableFromFile(connection, model[1], model[2])
  })
}

