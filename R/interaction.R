



rjs.session.create <- function(host="localhost", port = 1337) {

  packet.reader <- function() {
    private <- environment()


    private$init = function() {
      private$size = "";
      private$remaining = NULL;
      private$data = "";
      private$focus = "size";
    };

    private$init();

    private$reset = function() {
      private$init();
    };

    private$onData = function(data) {

      if(private$focus == "size") {

        semi = regexpr(";",data)[1];

        if(semi == -1) {
          private$size = paste(private$size, data, sep="");
          #writeLines("Waiting for more data to determine size...");
          return(NULL);
        } else {
          private$size = paste(private$size, substring(data, 1, semi-1), sep="");
          private$remaining = as.numeric(private$size);
          #writeLines("Determined size: ");
          private$focus = "read";
          data = substring(data, semi+1);
        }

      }

      if(private$focus == "read") {
        #writeLines("Reading the data...");

        private$data = paste(private$data, data, sep="");
        private$remaining = private$remaining - nchar(data);

        if(private$remaining == 0) {
          #writeLines("Done! Returning packet");
          return(private$data);
        }

        #writeLines("Waiting for more data...");
      }

      return(NULL);
    };

    structure(environment(), class=c("rjs.packet.reader", "environment"))
  }

  private <- environment()

  this <- local({

    #private$socket <- socketConnection(host = host, port = port, server = FALSE, blocking = TRUE, open = "r+", timeout=1, encoding="UTF-8")
    private$socket <- make.socket(host=host, port=port, server=FALSE)

    private$reader <- packet.reader()

    private$send <- function(data) {
      #writeLines(con=private$socket, text = data)
      write.socket(private$socket, as.character(nchar(data)))
      write.socket(private$socket, ";")
      write.socket(private$socket, data)
    }

    private$receive <- function() {
      #readLines(con = private$socket)
      data <- NULL
      while(is.null(data)) {
        data <- private$reader$onData(read.socket(private$socket))
      }
      private$reader$reset()
      return(data)
    }

    private$close <- function() {
      #base::close(private$socket)
      close.socket(private$socket)
    }

    private$eval <- function(line, raw = FALSE, intermediate.output=TRUE) {
      private$send(line)
      if(raw) {
        return(private$receive())
      } else {

        while(TRUE) {
          result <- jsonlite::fromJSON(private$receive())
          if("output" %in% names(result)) {
            if(nchar(result$output) > 0) {
              cat(result$output,"\n")
            }
          }
          if(length(result)==0) {
            break
          }
          if("error" %in% names(result)) {
            message(result$error)
            if("result" %in% names(result)) {

            } else {
              break
            }
          }
          if("result" %in% names(result)) {
            return(result$result)
          }
          if(intermediate.output==FALSE) {
            break
          }
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



