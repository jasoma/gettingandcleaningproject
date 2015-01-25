
# create a vector containing the names of columns in the 'combined' data frame that are
# measurements and not identifiers of some kind
obs.cols <- names(combined)
obs.cols <- obs.cols[!(obs.cols %in% c("subject_id", "activity", "source"))]

# create the set to hold all the averaged data, starts empty
averages <- data.frame()

# loop over each unique subject/activity pair in the data set. for each one collect all the associated
# measurements and calculate the means into a new data frame. join each of the individual frames into
# back into the 'averages' set.
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
