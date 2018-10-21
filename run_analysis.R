library(data.table)
library(dplyr)

#create and set directory 
if (!dir.exists("./JH Data Science")){dir.create("./JH Data Science")}
setwd("./JH Data Science")


# Create temporary file to store the zip file
sourcefile <- tempfile()
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", 
              destfile = sourcefile)

#unzip file
sourcefile <- unzip(sourcefile) 
sourcefile

#read the necessary file
activityLabel <- fread(sourcefile[[1]])
str(activityLabel)
features <- fread(sourcefile[[2]])
str(features)
testSubject <- fread(sourcefile[[14]])
testX <- fread(sourcefile[[15]])
testY <- fread(sourcefile[[16]])
trainSubject <- fread(sourcefile[[26]])
trainX <- fread(sourcefile[[27]])
trainY <- fread(sourcefile[[28]])


#merge data into respective column 
Subject <- rbind(testSubject, trainSubject)
activity_label <- rbind(testY, trainY)
activity_data <- rbind(testX, trainX)

nrow(Subject)
nrow(activity_label)
nrow(activity_data)

#merge all columns into a complete dataset and rename columns
fullset <- cbind(Subject, activity_label, activity_data)
names(fullset) <- c(c("subject", "activity_label"), as.character(features$V2))
str(fullset)


#extract the mean and std data
valid_column_names <- make.names(names=names(fullset), unique=TRUE, allow_ = TRUE)
names(fullset) <- valid_column_names
meanSDset <- select(.data = fullset, subject, activity_label,
                    grep("mean", names(fullset)), grep("std", names(fullset)))
str(meanSDset)


#assign descriptive name to activity label
meanSDset$activity_label <- activityLabel$V2[meanSDset$activity_label]
meanSDset$activity_label

#Appropriately labels the data set with descriptive variable names
names(meanSDset) <- gsub("^t", "Time", names(meanSDset))
names(meanSDset) <- gsub("f", "Freq", names(meanSDset))
names(meanSDset) <- gsub("Acc", "Accelerator", names(meanSDset))
names(meanSDset) <- gsub("Gyro", "Gyroscope", names(meanSDset))
names(meanSDset) <- gsub("BodyBody", "Body", names(meanSDset))
names(meanSDset) <- gsub("Mag", "Magnitude", names(meanSDset))


#Create Indenendent Tidy Dataset
tidyData <- aggregate(meanSDset[, 3:ncol(meanSDset)], list(meanSDset$subject, meanSDset$activity_label), mean)
colnames(tidyData)[1] <- "SubjectID"
colnames(tidyData)[2] <- "Activity_Label"

write.table(tidyData, file = "tidy.txt", row.names = FALSE)
fread("tidy.txt")

str(tidyData)
