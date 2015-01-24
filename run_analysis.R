
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