# Hello, world!
#
# This is an example function named 'hello'
# which prints 'Hello, world!'.
#
# You can learn more about package authoring with RStudio at:
#
#   http://r-pkgs.had.co.nz/
#
# Some useful keyboard shortcuts for package authoring:
#
#   Build and Reload Package:  'Ctrl + Shift + B'
#   Check Package:             'Ctrl + Shift + E'
#   Test Package:              'Ctrl + Shift + T'

#hide for now
local({

setupDevTools <- function() {
  tryCatch(library(devtools), error = function(e){
    install.packages("devtools")
  }, finally = function(e) {
    library(devtools)
  })

}

setupInstallR <- function() {
  tryCatch(library(installr), error = function(e){
    devtools::install_github('talgalili/installr')
  }, finally = function(e) {
    library(installr)
  })
}

setupJSONLite <- function() {
  tryCatch(library(jsonlite), error = function(e){
    install.packages("jsonlite")
  }, finally = function(e) {
    library(jsonlite)
  })
}

setupNodeJS <- function() {
  setupDevTools()
  setupInstallR()
}

})
