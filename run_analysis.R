##########################################################################################################
# Getting and Cleaning Data 
# Course Project
# Christopher H. Lyman
# 2015-11-15
#
# runAnalysis.R 
#
# Data: 
# https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 
# 
# Description:
# 1. Merge the training and the test sets to create one data set.
# 2. Extract only the measurements on the mean and standard deviation for each measurement. 
# 3. Use descriptive activity names to name the activities in the data set
# 4. Appropriately label the data set with descriptive activity names. 
# 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject. 
#
##########################################################################################################

library(reshape2)

#set working directory to the location where the UCI HAR Dataset was unzipped:
setwd("C:\\Users\\Steady\\Documents\\DataScienceSpecialization\\03_Getting_and_Cleaning_Data\\CourseProject\\UCI HAR Dataset")

# 1. Load activity labels + features
activityLabels <- read.table("activity_labels.txt")
# activityLabels[,2] <- as.character(activityLabels[,2])
features <- read.table("features.txt")
# features[,2] <- as.character(features[,2])

# 2. Extract rows with mean and standard deviation in features
extractedData <- grep(".*mean.*|.*std.*", features[,2])
extractedLabels <- features[extractedData,2]

# 3. Clean up and create Appropriate Descriptive Variables
extractedLabels <- gsub("-mean", "Mean", extractedLabels)
extractedLabels <- gsub("-std", "Std", extractedLabels)
extractedLabels <- gsub("fBody", "frequencyBody", extractedLabels)
extractedLabels <- gsub("tBody", "timeBody", extractedLabels)
extractedLabels <- gsub("tGravity", "timeGravity", extractedLabels)
extractedLabels <- gsub("[-()]", "", extractedLabels)

# 4. Load the the training datasets
xTrain <- read.table("train/X_train.txt")[extractedData]
yTrain <- read.table("train/Y_train.txt")
subjectTrain <- read.table("train/subject_train.txt")
trainData <- cbind(subjectTrain, yTrain, xTrain)

# 5. Load the the test datasets
xTest <- read.table("test/X_test.txt")[extractedData]
yTest <- read.table("test/Y_test.txt")
subjectTest <- read.table("test/subject_test.txt")
testData <- cbind(subjectTest, yTest, xTest)

# 6. combine Train and Test datasets and add variable names
oneData <- rbind(trainData, testData)
colnames(oneData) <- c("subject", "activity", extractedLabels)

# 7. turn IDs into factors
oneData$activity <- factor(oneData$activity, levels = activityLabels[,1],
                           labels = activityLabels[,2])
oneData$subject <- as.factor(oneData$subject)

# 8. Melt and dcast the combined dataset
meltedData <- melt(oneData, id = c("subject", "activity"))
meanData <- dcast(meltedData, subject + activity ~ variable, mean)

# 9. Write tidyData.txt
write.table(meanData, "tidyData.txt", row.names = FALSE, quote = FALSE)