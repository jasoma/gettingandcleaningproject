
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

# TODO: Automatically download the dataset if missing

# Read in the file containing the labels for the columns in the 'X' data files
features.all <- read.table("data/features.txt", colClasses = c("numeric", "character"), col.names = c("index", "label"))

# subset to only those we care about
# NOTE: It's unclear from the description if meanFreq() is considered a mean, the pattern
# below will retain it.
features.mean_std <- grep("-mean|-std", features.all$label, value = TRUE)
features <- features.all[features.all$label %in% features.mean_std, ]

# when loading the 'X_' data files we want to discard the columns that are not a mean or std column.
# to do that we construct a character vector to pass to colClasses where columns we want have a class
# of 'numeric' and columns we don't have 'NULL' which will cause `read.table` to discard them.
is.mean_std <- function(index) {
    index %in% features$index
}

data.cols <- sapply(seq(1, max(features.all$index)), function(x) if(is.mean_std(x)) "numeric" else "NULL")

# now we can read in either of the two data files
read.xfile <- function(filename, ...) {
    # read the file passing in the classes vector we assembled
    df <- read.table(filename, colClasses = data.cols, ...)
    # set the column names from the features data
    names(df) <- features$label
    df
}

# get the listing of activity code to activity name
activitylabels <- read.table("data/activity_labels.txt", colClasses = c("numeric", "character"), col.names = c("code", "label"))

# reading the 'y_' files is much easier, it only contains one column which is the activity factor
read.yfile <- function(filename) {
    df <- read.table(filename, colClasses = "factor", col.names = "activity")
    # set the factor names based on the 'activity_labels.txt' content
    levels(df$activity) <- activitylabels$label
    df
}

# likewise the subject files is easy, no need to even play with factor naming
read.subjectfile <- function(filename) {
    read.table(filename, colClasses = "numeric", col.names = "subject_id")
}
