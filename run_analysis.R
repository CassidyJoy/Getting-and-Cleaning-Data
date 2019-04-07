install.packages("data.tables")
install.packages("reshape2")
library(dplyr)

## Downloading and unzipping data

filename <- "UCIHARdata.zip"
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
dir <- "UCI HAR Dataset"

if(!file.exists(filename)){
	download.file(url,filename, mode = "wb")
}

if(!file.exists(dir)){
	unzip("UCIHARdata.zip", files = NULL, exdir=".")
}


## Read Data
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt", col.names = "subject")
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt", col.names = "subject")
X_test <- read.table("UCI HAR Dataset/test/X_test.txt", col.names = features$functions)
X_train <- read.table("UCI HAR Dataset/train/X_train.txt", col.names = features$functions)
y_test <- read.table("UCI HAR Dataset/test/y_test.txt", col.names = "code")
y_train <- read.table("UCI HAR Dataset/train/y_train.txt", col.names = "code")

activity <- read.table("UCI HAR Dataset/activity_labels.txt", col.names = c("code", "activity"))
features <- read.table("UCI HAR Dataset/features.txt", col.names = c("n", "functions"))


##run_Analysis
#Merges the training and the test sets to create one data set.
TestData <- cbind(subject_test, X_test, y_test)
TrainData <- cbind(subject_train, X_train, y_train)
dataSet <- rbind(TestData, TrainData)


#Extracts only the measurements on the mean and standard deviation for each measurement
TidyData <- dataSet %>% select(subject, code, contains("mean"), contains("std"))


#Uses descriptive activity names to name the activities in the data set
TidyData$code <- activity[TidyData$code, 2]


#Appropriately labels the data set with descriptive variable names
names(TidyData)[2] = "activity"
names(TidyData)<-gsub("Acc", "Accelerometer", names(TidyData))
names(TidyData)<-gsub("Gyro", "Gyroscope", names(TidyData))
names(TidyData)<-gsub("BodyBody", "Body", names(TidyData))
names(TidyData)<-gsub("Mag", "Magnitude", names(TidyData))
names(TidyData)<-gsub("^t", "Time", names(TidyData))
names(TidyData)<-gsub("^f", "Frequency", names(TidyData))
names(TidyData)<-gsub("tBody", "TimeBody", names(TidyData))
names(TidyData)<-gsub("-mean()", "Mean", names(TidyData), ignore.case = TRUE)
names(TidyData)<-gsub("-std()", "STD", names(TidyData), ignore.case = TRUE)
names(TidyData)<-gsub("-freq()", "Frequency", names(TidyData), ignore.case = TRUE)
names(TidyData)<-gsub("angle", "Angle", names(TidyData))
names(TidyData)<-gsub("gravity", "Gravity", names(TidyData))


#creates a second, independent tidy data set with the average of each variable for each activity and each subject.
FinalData <- TidyData %>%
    group_by(subject, activity) %>%
    summarise_all(list(mean))
write.table(FinalData, "FinalData.txt", row.name=FALSE)
