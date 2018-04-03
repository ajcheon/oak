library(ggplot2)
library(reshape2)
library(plyr)

df = read.csv("./csvs/oakSecWaitTimes.csv")
summary(df)

meltedDf = melt(df, value.name = "waitTimes")

# Get mean wait times
meanWaitTimes <- ddply(meltedDf, "variable", summarise, wait.mean=mean(waitTimes))

# Density plot of wait times for each condition
ggplot(meltedDf, aes(x=waitTimes, color=variable)) +
    geom_density() +
    geom_vline(data=meanWaitTimes, aes(xintercept=wait.mean, color=variable),
               linetype="dashed")

# Boxplot of wait times for each condition
ggplot(meltedDf, aes(variable, waitTimes)) +
    geom_boxplot() +
    geom_jitter(width = 0.1)

ggplot(meltedDf, aes(waitTimes, color="black")) +
    geom_histogram(position = "dodge", binwidth = 5)
