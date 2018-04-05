
server <- rjs.server()

status <- server$start()

session <- server$session()

session$eval("a=3")

session$eval("a")

session$assign("df",mtcars)
session$assign("df",mtcars, dataframe="values")

session$assign("message","hello world!")

session$get("df")

session$get("message")

session$eval("c")

session$eval("console.log('hello!afwafawfaw')")

session$eval("var fs = require('fs');")

