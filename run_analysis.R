
# Notes:
#
# Each line in the 'X' file is a complete set of feature observations where the values are separated by spaces.
# The index of each value within a line matches it to the feature number in 'features.txt', combining the two
# will give you a table where the columns are features and the rows the measured value.
#
# Each line in the 'Y' file is linked to the same line number in the 'X' file and records what type of activity
# the measurements are from. The coding from number to activity type is in 'activity_labels.txt'.
#
# Each line in the 'subject' file is linked to the same line number in the 'X' file and records the ID of the
# person who was wearing the device.
#
# To combine all three files to produce a tidy set we need to:
#
# - Decide which row inidicies in 'X' we want to keep by looking at the names in 'activity_labels', we only
#   want to keep rows with indicies where the description has 'mean' or 'std' in it
# - Read in only the rows we care about and name them at the same time using the vector created above
#   http://stackoverflow.com/questions/5788117/only-read-limited-number-of-columns-in-r
# - Read in the auxilary files containing subjectId and activity and bind them by column into the data set


# == Data loading ==

#' The file 'features.txt' contains the column descriptions for each of the rows in the 'X_' data files.
#' We only want to deal with those columns that descript the mean or standard deviation. This variable
#' contains a data frame with two columns:
#'
#'      'index': A column index in either of the 'X_' files
#'      'label': The descriptive label of the contents of that column
#'
#' The contents of the files have been subsetted to remove any entries that do not describe a mean or
#' standard deviation. As such the 'index' row is not continuous, it has gaps corresponding to columns
#' that we do *not* want to read in.
features <- {
    # Read in the file containing all the labels
    .features.all <- read.table("data/features.txt",
                                colClasses = c("numeric", "character"),
                                col.names = c("index", "label"))
    # subset to only those we care about, that is only those that have 'mean' or 'std' in the label
    .features.all[.features.all$label %in% grep("-mean|-std", .features.all$label, value = TRUE), ]
}

# when loading the 'X_' data files we want to discard the columns that are not a mean or std column.
# to do that we construct a character vector to pass to colClasses where columns we want have a class
# of 'numeric' and columns we don't have 'NULL' which will cause `read.table` to discard them.

#' Simple function that takes a column index and returns `TRUE` if that index is for a 'mean' or 'std'
#' column as described by `features`.
#'
#' @param index the index to test
#' @return `TRUE` if the index is contained in `features`, `FALSE` if not.
is.mean_std <- function(index) {
    index %in% features$index
}

#' Reads in a data file treating as one of the 'X_' files that contains rows of unlabeled sensor data.
#' Uses `features` and `is.mean_std` in order to read in only those columns that are a 'mean' or 'std'
#' of a measurement.
#'
#' @param filename the path to the file to read
#' @return a `data.frame` containing only the columns in the file that correspond to `features$index`
#'         labeled with `features$label`
read.xfile <- function(filename) {

    # to avoid reading and then discarding the data we don't want use `features` to create a class name
    # vector for passing to 'colClasses' in `read.table`. for columns we want to keep the vector should
    # contain 'numeric' for those we want to drop the vector should contain 'NULL'
    data.cols <- sapply(seq(1, max(.features.all$index)), function(x) if(is.mean_std(x)) "numeric" else "NULL")

    # read the file passing in the classes vector we assembled
    df <- read.table(filename, colClasses = data.cols)

    # set the column names from the features data
    names(df) <- features$label

    # then replace '-' and '()' in the names so they can be used unquoted in the rest of the script
    names(df) <- gsub("()", "", names(df), fixed = TRUE)
    names(df) <- gsub("-", "_", names(df), fixed = TRUE)
    df
}

# reading the 'y_' files is much easier, it only contains one column which is the activity factor

#' Reads in a data file treating it as one of the 'y_' files that contain activity codes that correspond
#' to the equivalent row in an 'X_' file.
#'
#' @param filename the path to the file to read.
#' @return a `data.frame` consisting of a single column 'activity' where each row corresponds to the
#'         same number row in an 'X_' file and contains the activity name for the measurements in that
#'         row.
read.yfile <- function(filename) {
    # read in 'activity_labels.txt' to get the mapping from activity code to human-friendly names
    activitylabels <- read.table("data/activity_labels.txt",
                                 colClasses = c("numeric", "character"),
                                 col.names = c("code", "label"))

    #' read in the file and make it's only column a factor
    df <- read.table(filename, colClasses = "factor", col.names = "activity")

    # set the factor names
    levels(df$activity) <- activitylabels$label
    df
}

# likewise the subject files is easy, no need to even play with factor naming

#' Reads in a data file treating it as one of the 'subject_' files that contain the id of the subject
#' that performed the activity.
#'
#' @param filename the path to the file to read.
#' @return a `data.frame` consisting of a single column 'subject_id' where each row corresponds to the
#'         same number row in an 'X_' file and contains the id of the subject that performed the activity
#'         measured in that row.
read.subjectfile <- function(filename) {
    read.table(filename, colClasses = "numeric", col.names = "subject_id")
}

#' Reads in all the 'test' and 'train' data using the functions above and then combines the two sets
#' into a single data frame and returns it.
#'
#' @return a combined `data.frame` of all the 'test' and 'train' data.
read.data <- function() {

    # TODO: Automatically download the dataset if missing

    # load all the training files and combine them into one frame
    train.dir <- "data/train"
    train.x <- read.xfile(file.path(train.dir, "X_train.txt"))
    train.y <- read.yfile(file.path(train.dir, "y_train.txt"))
    train.subj <- read.subjectfile(file.path(train.dir, "subject_train.txt"))
    train <- cbind(train.subj, train.y, train.x)

    # load all the test files and combine them
    test.dir <- "data/test"
    test.x <- read.xfile(file.path(test.dir, "X_test.txt"))
    test.y <- read.yfile(file.path(test.dir, "y_test.txt"))
    test.subj <- read.subjectfile(file.path(test.dir, "subject_test.txt"))
    test <- cbind(test.subj, test.y, test.x)

    # add an extra column to each set for identifying it's origin then merge the two
    sourcetype <- factor(c("train", "test"))
    train$source <- sourcetype[1]
    test$source <- sourcetype[2]
    combined <- rbind(train, test)

    # sort by subject and activity so it looks nice to humans and return
    combined <- combined[order(combined$subject_id, combined$activity), ]
    combined
}

#' This variable contains the combined data from `read.data`
combined <- read.data()


# == Subject/Activity analysis ==

#' Calculates the averages of each measurement in `combined` for each subject/activity pair.
#'
#' @return a `data.frame` containing one row for each subject/activity pair where the measurements
#'         in the row are the average of each individual observation for that pair in the `combined`
#'         data set.
calc.averages <- function() {
    # create a vector containing the names of columns in the 'combined' data frame that are
    # measurements and not identifiers of some kind
    obs.cols <- names(combined)
    obs.cols <- obs.cols[!(obs.cols %in% c("subject_id", "activity", "source"))]

    # create the set to hold all the averaged data, starts empty
    averages <- data.frame()

    # loop over each unique subject/activity pair in the data set. for each one collect all the associated
    # measurements and calculate the means into a new data frame. join each of the individual frames back
    # into the 'averages' set.
    for (id in unique(combined$subject_id)) {
        for (act in levels(combined$activity)) {
            # make a subset containing only the observations for this subject/activity
            subjmeans <- combined[with(combined, subject_id == id & activity == act), obs.cols]

            # get the means of all the observations
            subjmeans <- colMeans(subjmeans)

            # add the identifiers back (excluding source which no longer has any meaning since we have
            # merged all the data together regardless of source) and convert back to a data fram.
            subjmeans$subject_id <- id
            subjmeans$activity <- act
            subjmeans <- data.frame(subjmeans)

            # merge into the main set
            averages <- rbind(averages, subjmeans)
        }
    }

    # reorder the columns in the set so the identifiers are all on the left and the measurements all
    # on the right
    averages <- averages[, c(80, 81, 1:79)]
    averages
}

#' This variable contains the averaged data from combined
averages <- calc.averages()
write.table(averages, file = "averages.txt", row.names = FALSE)
