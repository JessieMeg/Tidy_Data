

## You should create one R script called run_analysis.R that does the following: 
## 1. Merges the training and the test sets to create one data set.
## 2. Extracts only the measurements on the mean and standard deviation for 
##    each measurement. 
## 3. Uses descriptive activity names to name the activities in the data set
## 4. Appropriately labels the data set with descriptive variable names. 
## 5. Creates a second, independent tidy data set with the average of each 
##    variable for each activity and each subject. 

## Set working directory as the folder you want the cleaned file saved in.
## The unzipped data should be in the same location.
## Load package plyr.
install.packages("plyr")
library(plyr)

## First, start with the original separate data files
## Read in the data for both the test and training sets
trainX <- read.table("UCI_HAR_Dataset/train/X_train.txt")
testX <- read.table("UCI_HAR_Dataset/test/X_test.txt")

## Read the column labels from the same folders
features <- read.table("UCI_HAR_Dataset/features.txt")
activities <- read.table("UCI_HAR_Dataset/activity_labels.txt", col.names = c("labels", "activity"))

## Apply them to the data you just created
names(trainX) <- features[,2]
names(testX) <- features[,2]

## Merge the training and test data into one dataset
trainTestX <- rbind(trainX,testX)

## Read in and combine the test and training activity labels
trainY <- read.table("UCI_HAR_Dataset/train/y_train.txt", col.names = c("labels"))
testY <- read.table("UCI_HAR_Dataset/test/y_test.txt", col.names = c("labels"))
labels <- rbind(trainY,testY)

## Read in and combine the test and training subject lists
trainSubj <- read.table("UCI_HAR_Dataset/train/subject_train.txt", col.names = c("subject"))
testSubj <- read.table("UCI_HAR_Dataset/test/subject_test.txt", col.names = c("subject"))
subjects <- rbind(trainSubj, testSubj)

## Use pattern matching to select mean and std deviation terms
meanStd <- grep("mean|std", names(trainTestX))
trainTestXFiltered <- trainTestX[,meanStd]
meanFreq <- grep("meanFreq", names(trainTestXFiltered))
trainTestXFiltered <- trainTestXFiltered[,-meanFreq]

## Apply the activity labels and subject labels to the data
trainTestXYFiltered <- cbind(trainTestXFiltered, labels)
trainTestXYSFiltered <- cbind(trainTestXYFiltered, subjects)

## Apply the descriptive activity names to the data
filteredXYS <- merge(trainTestXYSFiltered, activities, all = TRUE, sort = FALSE)

## Calculate the average of each variable grouped by subject and activity
dResults <- ddply(filteredXYS, c("subject", "activity"), colwise(mean))

## Create a text file with the clean dataset
write.table(dResults, file = "tidy_data.txt", sep = ",", row.names = FALSE)