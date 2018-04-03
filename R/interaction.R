
rjs.session.create <- function(host="localhost", port = 1337) {

  private <- environment()

  this <- local({

    #private$socket <- socketConnection(host = host, port = port, server = FALSE, blocking = TRUE, open = "r+", timeout=1, encoding="UTF-8")
    private$socket <- make.socket(host=host, port=port, server=FALSE)

    private$send <- function(data) {
      #writeLines(con=private$socket, text = data)
      write.socket(private$socket, as.character(nchar(data)))
      write.socket(private$socket, ";")
      write.socket(private$socket, data)
    }

    private$receive <- function() {
      #readLines(con = private$socket)
      read.socket(private$socket)
    }

    private$close <- function() {
      #base::close(private$socket)
      close.socket(private$socket)
    }

    private$eval <- function(line, raw = FALSE) {
      private$send(line)
      if(raw) {
        return(private$receive())
      } else {
        result <- jsonlite::fromJSON(private$receive())
        if("error" %in% names(result)) {
          message(result$error)
        }
        if("output" %in% names(result)) {
          if(nchar(result$output) > 0) {
            cat(result$output,"\n")
          }
        }
        if(length(result)==0) {
          return(list(result=NULL))
        }
        if("result" %in% names(result)) {
          return(result$result)
        }
        invisible()
      }
    }

    private$assign <- function(name, value) {
      private$eval(paste("var",name,"=",jsonlite::toJSON(value),";", sep=" "))
    }

    private$get <- function(name) {
      private$eval(name)
    }



  })

  structure(environment(), class=c("rjs.session", "environment"))
}
