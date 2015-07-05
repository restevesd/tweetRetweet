require('DBI')

capitalize <- function(chars) {
  paste0(toupper(substring(chars, 1, 1)), substring(chars, 2))
}

getColumn <- function(connection, model, column.names) {
  cols.txt <- paste(column.names, collapse=', ')
  query.txt <- paste("SELECT", cols.txt, "FROM", model)
  res <- dbSendQuery(connection, query.txt)
  res.df <- dbFetch(res)
  dbClearResult(res)
  res.df
}

eliminateDuplicates <- function(df, pk='id') {
  subset(df, !duplicated(df[pk]))
}

selectNewRows <- function(df, df.old, pk='id') {
  rownames(df) <- c() # somehow we need to remove rownames
  df <- eliminateDuplicates(df, pk)
  if (dim(df.old)[1]!=0) {
    df.old$dbWriteNewRowsControllX152 <- rep('old',dim(df.old)[1])
    mergedDF <- merge(df, df.old, all.x=TRUE, by=pk, sort = FALSE)
    ines.new <- which(is.na(mergedDF$dbWriteNewRowsControllX152))
    if (length(ines.new)!=0) {
      n <- length(colnames(mergedDF))
      df.new <- mergedDF[is.na(mergedDF$dbWriteNewRowsControllX152),-n]
      if (dim(df)[2]==1) {
        df.new <- data.frame(df.new)
        colnames(df.new)=colnames(df)
      } else {
        df.new <- df.new[colnames(df)]
      }
    } else {
      df.new <- NULL
    }
  } else {
    df.new <- df
  }
  df.new
}

dbWriteNewRows <- function(connection, model, df, pk='id') {
  rownames(df) <- c() # somehow we need to remove rownames
  if (dbExistsTable(connection, model)) {
    ## df.old <- getColumn(connection, model, pk)
    df.old <- dbReadTable(connection, model)[pk]
    df.new <- selectNewRows(df, df.old, pk)
    if (!is.null(df.new)) {
      ## if (dim(df.old)[1]==0) {
      ##   dbWriteTable(connection, model, df, overwrite=TRUE)
      ## }
      dbWriteTable(connection, model, df.new, append=TRUE)
    }
  } else {
    dbWriteTable(connection, model, df)
    df.new <- df
  }
  df.new
}

joinModelName <- function(s1, s2) {
  models <- sort(c(s1,s2))
  paste0(models[1],capitalize(models[2]))
}

dbAddChildrenM2M <- function(connection,
                             father.model, father.row, 
                             children.model, children.df,
                             father.pk='id', children.pk='id',
                             through=NULL) {
  dbWriteNewRows(connection, father.model, father.row, pk=father.pk)
  newChildren <- dbWriteNewRows(connection, children.model, children.df, pk=children.pk)
  if (is.null(through)) {
    join.model <- joinModelName(father.model, children.model)
    father.cname <- paste0(father.model,'_fk')
    children.cname <- paste0(children.model,'_fk')
    children.pks <- children.df[[c(children.pk)]]
    n <- length(children.pks)
    join.df <- data.frame(c(children.pks), rep(father.row[[father.pk]], n))
    join.colnames <- c(children.cname, father.cname)
    colnames(join.df) <- join.colnames
    dbWriteNewRows(connection, join.model, join.df, pk=join.colnames)
  }
  newChildren
}

dbReadChildrenM2M <- function(connection,
                             father.model, father.pk.value, 
                             children.model,
                             father.pk='id', children.pk='id',
                             n.fetch=1000,
                             through=NULL
                             ) {
  join.model <- joinModelName(father.model, children.model)
  father.cname <- paste0(father.model,'_fk')
  children.cname <- paste0(children.model,'_fk')
  query <- paste0(
    'SELECT DISTINCT * ',
    ' FROM ',
    children.model, ' JOIN ',
      '(SELECT ', children.cname,
      ' FROM ', 
      join.model, ', ',  father.model,
      ' WHERE ',
      father.cname, '=', father.pk, ' AND ',
      father.pk,'=', '"', father.pk.value, '"',
      ') ',
    'ON ',
    children.cname, '=', children.pk,
    ';')
  res <- dbSendQuery(connection, query)
  res.df <- dbFetch(res, n=n.fetch)
  dbClearResult(res)
  n <- dim(res.df)[2]
  res.df[,-n]
};


dbRemoveTableIfExists <- function(connection, model) {
  if (dbExistsTable(connection, model)) {
    dbRemoveTable(connection, model)
  }
}
