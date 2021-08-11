rm(list=ls())

library("cjoint")
library("sandwich")
library("ggplot2")
library("rio")
library(dummy)
library(xtable)

setwd("C:/Users/Torben/Dropbox/Torben-Nate Projects/Political Risk")

dataset <- import("JensenBehmer_Conjoint.dta")
#design <- makeDesign(type="file", filename="risk_randomization_design.dat")


dataset$Size <- as.factor(dataset$Size)
dataset$Investor <- as.factor(dataset$Investor)
dataset$Treaties <- as.factor(dataset$Treaties)
dataset$Aid <- as.factor(dataset$Aid)
dataset$Risk <- as.factor(dataset$Risk)
dataset$Industry <- as.factor(dataset$Industry)



## Define reference categories for each variable: Country-var example below:
dataset$Size <- relevel(dataset$Size, ref="Medium (Between 100-1000 employees)")
dataset$Investor <- relevel(dataset$Investor, ref="Investor is from the U.S.")
dataset$Treaties <- relevel(dataset$Treaties, ref="None")
dataset$Aid <- relevel(dataset$Aid, ref="Aid from investor country")
dataset$Risk <- relevel(dataset$Risk, ref="OECD Country risk rating of 4")
dataset$Industry <- relevel(dataset$Industry, ref="Manufacturing for sale to host market")

nonmiss <- dataset[!is.na(dataset$choice), ]

use<-subset(nonmiss,select=c(choice, Size, Investor, Treaties, Aid, Risk, Industry, id))

# AMCEs only
results_use <- amce(choice ~ Size + Investor + Treaties + Aid + Risk + Industry , data=use, cluster=TRUE, respondent.id="id", design="uniform")

# Print summary
summary(results_use)

# Plot results
pdf("risk_overall_new.pdf", width=14)
plot(results_use, xlab="Change in Pr(Less Risk)", main="AMCE",
     xlim=c(-.3,.3), breaks=c(-.3,-.2,-.1,0,.1,.2,.3), 
     labels=c("-.3","-.2","-.1","0","1",".2",".3"), text.size=12
)
dev.off()


## AMCEs and ACIEs
results_interact <- amce(choice ~ Size + Investor + Treaties + Aid + Risk + Industry + Investor:Treaties + Investor:Aid , data=use, cluster=TRUE, respondent.id="id", design="uniform")

# Print summary
summary(results_interact)

# Plot results
pdf("risk_interactive.pdf", width=14)
plot(results_interact, xlab="Change in Pr(Less Risk)",
     xlim=c(-.3,.3), breaks=c(-.3,-.2,-.1,0,.1,.2,.3), 
     labels=c("-.3","-.2","-.1","0","1",".2",".3"), text.size=10, facet.names=c("Aid", "Treaties"), plot.display="interaction"
)
dev.off()

## Other Robustness
dataset <- import("JensenBehmer_Cj_short.dta")
#design <- makeDesign(type="file", filename="risk_randomization_design.dat")


dataset$Size <- as.factor(dataset$Size)
dataset$Investor <- as.factor(dataset$Investor)
dataset$Treaties <- as.factor(dataset$Treaties)
dataset$Aid <- as.factor(dataset$Aid)
dataset$Risk <- as.factor(dataset$Risk)
dataset$Industry <- as.factor(dataset$Industry)



## Define reference categories for each variable: Country-var example below:
dataset$Size <- relevel(dataset$Size, ref="Medium (Between 100-1000 employees)")
dataset$Investor <- relevel(dataset$Investor, ref="Investor is from the U.S.")
dataset$Treaties <- relevel(dataset$Treaties, ref="None")
dataset$Aid <- relevel(dataset$Aid, ref="Aid from investor country")
dataset$Risk <- relevel(dataset$Risk, ref="OECD Country risk rating of 4")
dataset$Industry <- relevel(dataset$Industry, ref="Manufacturing for sale to host market")

nonmiss <- dataset[!is.na(dataset$choice), ]

use<-subset(nonmiss,select=c(choice, Size, Investor, Treaties, Aid, Risk, Industry, id))

# AMCEs only
results_use <- amce(choice ~ Size + Investor + Treaties + Aid + Risk + Industry , data=use, cluster=TRUE, respondent.id="id", design="uniform")

# Print summary
summary(results_use)

# Plot results
pdf("risk_short.pdf", width=14)
plot(results_use, xlab="Change in Pr(Less Risk)", main="AMCE: No short time intervals",
     xlim=c(-.3,.3), breaks=c(-.3,-.2,-.1,0,.1,.2,.3), 
     labels=c("-.3","-.2","-.1","0","1",".2",".3"), text.size=12
)
dev.off()

####
dataset <- import("JensenBehmer_Cj_job.dta")
#design <- makeDesign(type="file", filename="risk_randomization_design.dat")


dataset$Size <- as.factor(dataset$Size)
dataset$Investor <- as.factor(dataset$Investor)
dataset$Treaties <- as.factor(dataset$Treaties)
dataset$Aid <- as.factor(dataset$Aid)
dataset$Risk <- as.factor(dataset$Risk)
dataset$Industry <- as.factor(dataset$Industry)



## Define reference categories for each variable: Country-var example below:
dataset$Size <- relevel(dataset$Size, ref="Medium (Between 100-1000 employees)")
dataset$Investor <- relevel(dataset$Investor, ref="Investor is from the U.S.")
dataset$Treaties <- relevel(dataset$Treaties, ref="None")
dataset$Aid <- relevel(dataset$Aid, ref="Aid from investor country")
dataset$Risk <- relevel(dataset$Risk, ref="OECD Country risk rating of 4")
dataset$Industry <- relevel(dataset$Industry, ref="Manufacturing for sale to host market")

nonmiss <- dataset[!is.na(dataset$choice), ]

use<-subset(nonmiss,select=c(choice, Size, Investor, Treaties, Aid, Risk, Industry, id))

# AMCEs only
results_use <- amce(choice ~ Size + Investor + Treaties + Aid + Risk + Industry , data=use, cluster=TRUE, respondent.id="id", design="uniform")

# Print summary
summary(results_use)

# Plot results
pdf("risk_job.pdf", width=14)
plot(results_use, xlab="Change in Pr(Less Risk)", main="AMCE: Underwriters and Analysts only",
     xlim=c(-.3,.3), breaks=c(-.3,-.2,-.1,0,.1,.2,.3), 
     labels=c("-.3","-.2","-.1","0","1",".2",".3"), text.size=12
)
dev.off()
