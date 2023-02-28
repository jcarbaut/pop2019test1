library(magrittr)
library(dplyr)
library(stringr)
library(shiny)
library(shinyjs)
library(ggplot2)
library(openssl)

# Code JavaScript pour ouvrir un URL
js_code <- "
  shinyjs.browseURL = function(url) {
    window.open(url, '_blank');
  }
"

# Dossier pour les sorties
dir.create("www/output", recursive = T)

# Génération aléatoire de nom de fichier pour les sorties
tempname <- (function() {
  salt <- sha256(paste0(sample(letters, 50, replace = T), collapse = ""))
  count <- 0
  function() {
    count <<- count + 1
    paste0(sha256(paste0(salt, ",", count)), ".html")
  }
})()

source("cog.R", encoding = "UTF-8")

# Population communale au RP 2019

pop <-
  readRDS("data/popcom2019.rds") %>%
  mutate(dep = str_sub(depcom, 1, 2),
         dep = ifelse(dep == "97", str_sub(depcom, 1, 3), dep)) %>%
  left_join(tbl_depreg, by = "dep")

# Pour le selectInput, un vecteur nommé : libellé région = code région.
regs <- setNames(tbl_reg$reg, tbl_reg$libreg)
regs <- regs[order(names(regs))]

# Une autre façon de faire :
# regs <- c(
#   `Guadeloupe` = "01",
#   `Martinique` = "02",
#   `Guyane` = "03",
#   `La Réunion` = "04",
#   `Mayotte` = "06",
#   `Île-de-France` = "11",
#   `Centre-Val de Loire` = "24",
#   `Bourgogne-Franche-Comté` = "27",
#   `Normandie` = "28",
#   `Hauts-de-France` = "32",
#   `Grand Est` = "44",
#   `Pays de la Loire` = "52",
#   `Bretagne` = "53",
#   `Nouvelle-Aquitaine` = "75",
#   `Occitanie` = "76",
#   `Auvergne-Rhône-Alpes` = "84",
#   `Provence-Alpes-Côte d'Azur` = "93",
#   `Corse` = "94"
# )
