library(rvest)
library(haven)
library(readr)
library(RSQLite)

con <- dbConnect(SQLite(), "testing")


url <- "https://en.wikipedia.org/wiki/French_presidential_election,_2017"

votes <- read_html(url) %>% html_nodes(".wikitable")
vt <- html_table(votes[[1]], fill = TRUE)
vv <- vt[2:12, c(2, 3, 5) ]
vv$mem <- NA

vv$mem <- c("252,977", "85,000", "275,000", "434,961", 
            "42,300", "20,000", NA, "25,000", "2,100", "8,000", NA)

vv$ideol <- c("Left", "Right", "Right", "Left", "Left", "right", "Left", "Left", 
              "Right", "left", "left")

colnames(vv)[3] <- "votes1"


vvCSV <- vv[1:5, 1:3]
vvSAV <- vv[6:11, 1:3]
votesRDA <- vv[!is.na(vv$mem), c(2, 4, 5)]

write_csv(vvCSV, "votes.csv")
write_sav(vvSAV, "votes.sav")
save(votesRDA, file = "votes.Rda")
rm(list = ls())

##### Answers #####
library(dplyr)

a <- read_csv("votes.csv")
aa <- read.csv("votes.csv")
b <- read_sav("votes.sav")

load("votes.Rda")


b$votes1 <- as.numeric(gsub(",", "", b$votes1))
votes <- rbind(a, b)
votes <- left_join(votes, votesRDA)
View(votes)
votes$memx <- as.numeric(gsub(",", "", votes$mem))

votes$ideol <- tolower(votes$ideol)
str(votes)
votes %>% group_by(ideol) %>% summarise(v = sum(votes1))

votes$ideol[c(7, 11)] <- "left"



