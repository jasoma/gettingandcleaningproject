
# create a vector containing the names of columns in the 'combined' data frame that are
# measurements and not identifiers of some kind
obs.cols <- names(combined)
obs.cols <- obs.cols[!(obs.cols %in% c("subject_id", "activity", "source"))]

# make a subset containing only the observations for one subject and one activity
m <- combined[with(combined, subject_id == 1 & activity == "WALKING"), obs.cols]
# get the means of each measurement
m.means <- colMeans(m)

# add the identifiers back (excluding source which no longer has any meaning since we have
# merged all the data together regardless of source) and convert back to a data fram.
m.means$subject_id <- 1
m.means$activity <- "WALKING"
m.df <- data.frame(m.means)



# create the set to hold all the averaged data, starts empty
averages <- data.frame()

# loop over each unique subject/activity pair in the data set. for each one collect all the associated
# measurements and calculate the means into a new data frame. join each of the individual frames into
# back into the 'averages' set.
for (id in unique(combined$subject_id)) {
    for (act in levels(combined$activity)) {
        print(paste("averaging for ", id, act))
        # make a subset containing only the observations for this subject/activity
        subjmeans <- combined[with(combined, subject_id == id && activity == act), obs.cols]
        tmp <- sapply(subjmeans, function(x) any(is.nan(x)))
        print(paste("Number of cols with NaNs", length(tmp[tmp == T])))

        # get the means of all the observations
        subjmeans <- colMeans(subjmeans, na.rm = TRUE)
        print(paste("NaN in means?", any(is.nan(subjmeans))))

        # add the identifiers back (excluding source which no longer has any meaning since we have
        # merged all the data together regardless of source) and convert back to a data fram.
        subjmeans$subject_id <- id
        subjmeans$activity <- act
        subjmeans <- data.frame(subjmeans)

        # merge into the main set
        averages <- rbind(averages, subjmeans)
    }
}
