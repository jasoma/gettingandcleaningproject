

### Notes on the raw data structure

- Each row in an `X_*` file is a complete set of feature observations where the values are separated by spaces.
- The column-index of each value within a row matches it to the feature number in [features.txt](features.txt, combining the two will result in a table with a columns for each feature observation and rows of measurements.
- Each row in a `y_*` file is linked to the the row in the same position in a corresponding `X_*` file and records what type of activity the measurements are from. 
- The coding from number to activity type is in [activity_labels.txt](activity_labels.txt).
- Each row in a `subject_*` file is linked to the same row in a corresponding `X_*` file and records the ID of the person who was wearing the device that performed the measurements.

### Analysis

To combine all three files to produce a tidy set we need to:

- Decide which columns in the `X_*` files we want to load by looking at the contents of [features.txt](features.txt), we only want to load those that are a mean or standard deviation measurement.
- For each of the `test` and `train` data sets:
    - Load the `X_` file reading only the rows we want.
    - Load the `y_` file and combine it with the `X_` data.
    - Load the `subject_` file and combine it with the `X_` data.

### Variables

The following are all the variables loaded into the executing scope by the [analysis script](run_analysis.R).

#### combined

Contains the combined mean and standard deviation data from the `test` and `train` datasets. Has the following named columns:

- **subject_id**: The id of the person who performed the activity being measured.
- **activity**: The activity beaing measured.
- **source**: the source of the data (either 'test' or 'train')

All other columns have names matching those used in the README.txt accompianing the data, for convenience they are replicated here:


    The features selected for this database come from the accelerometer and gyroscope 3-axial raw signals tAcc-XYZ and tGyro-XYZ. These time domain signals (prefix 't' to denote time) were captured at a constant rate of 50 Hz. Then they were filtered using a median filter and a 3rd order low pass Butterworth filter with a corner frequency of 20 Hz to remove noise. Similarly, the acceleration signal was then separated into body and gravity acceleration signals (tBodyAcc-XYZ and tGravityAcc-XYZ) using another low pass Butterworth filter with a corner frequency of 0.3 Hz. 

    Subsequently, the body linear acceleration and angular velocity were derived in time to obtain Jerk signals (tBodyAccJerk-XYZ and tBodyGyroJerk-XYZ). Also the magnitude of these three-dimensional signals were calculated using the Euclidean norm (tBodyAccMag, tGravityAccMag, tBodyAccJerkMag, tBodyGyroMag, tBodyGyroJerkMag). 

    Finally a Fast Fourier Transform (FFT) was applied to some of these signals producing fBodyAcc-XYZ, fBodyAccJerk-XYZ, fBodyGyro-XYZ, fBodyAccJerkMag, fBodyGyroMag, fBodyGyroJerkMag. (Note the 'f' to indicate frequency domain signals). 

    These signals were used to estimate variables of the feature vector for each pattern:  
    '-XYZ' is used to denote 3-axial signals in the X, Y and Z directions.

    tBodyAcc-XYZ
    tGravityAcc-XYZ
    tBodyAccJerk-XYZ
    tBodyGyro-XYZ
    tBodyGyroJerk-XYZ
    tBodyAccMag
    tGravityAccMag
    tBodyAccJerkMag
    tBodyGyroMag
    tBodyGyroJerkMag
    fBodyAcc-XYZ
    fBodyAccJerk-XYZ
    fBodyGyro-XYZ
    fBodyAccMag
    fBodyAccJerkMag
    fBodyGyroMag
    fBodyGyroJerkMag

    The set of variables that were estimated from these signals are: 

    mean(): Mean value
    std(): Standard deviation
    ~~mad(): Median absolute deviation~~
    ~~max(): Largest value in array~~
    ~~min(): Smallest value in array~~
    ~~sma(): Signal magnitude area~~
    ~~energy(): Energy measure. Sum of the squares divided by the number of values. ~~
    ~~iqr(): Interquartile range ~~
    ~~entropy(): Signal entropy~~
    ~~arCoeff(): Autorregresion coefficients with Burg order equal to 4~~
    ~~correlation(): correlation coefficient between two signals~~
    ~~maxInds(): index of the frequency component with largest magnitude~~
    meanFreq(): Weighted average of the frequency components to obtain a mean frequency
    ~~skewness(): skewness of the frequency domain signal ~~
    ~~kurtosis(): kurtosis of the frequency domain signal ~~
    ~~bandsEnergy(): Energy of a frequency interval within the 64 bins of the FFT of each window.~~
    ~~angle(): Angle between to vectors.~~

    Additional vectors obtained by averaging the signals in a signal window sample. These are used on the angle() variable:

    gravityMean
    tBodyAccMean
    tBodyAccJerkMean
    tBodyGyroMean
    tBodyGyroJerkMean


Note that the description lists a large set of variables esitmated from the raw signal data. During analysis all but the `mean()` (or mean of a sub-variable) and `std()` variables are dropped. *In the listing above the dropped values are ~~crossed out~~.*

#### averages

A data frame containing the primary results of the analysis. Each measurement was broken down by subject and activity and an average taken of all results for each subject/activity pair.

This variable contains all the same columns as `combined` with the exception of the **source** column which is dropped. It contains only one row per subject/activity pair and the value in each column for that row is the average of all measurements for that pair.

#### features

A data frame containing the column labels and indicies of the data that was used from the raw data files. In the description of `combined` above it talks about using only the subset of measurements that were *means* or *standard deviations* this variables lists exactly which columns were used.

### Functions

The following are all the functions loaded into the executing scope by the [analysis script](run_analysis.R).

#### is.mean_standard

Simple function that takes a column index and returns `TRUE` if that index is for a 'mean' or 'std' column as described by `features`.

#### read.xfile

Reads in a data file treating as one of the 'X_' files that contains rows of unlabeled sensor data. Uses `features` and `is.mean_std` in order to read in only those columns that are a 'mean' or 'std' of a measurement.

#### read.yfile

Reads in a data file treating it as one of the 'y_' files that contain activity codes that correspond to the equivalent row in an 'X_' file.

#### read.subjectfile

Reads in a data file treating it as one of the 'subject_' files that contain the id of the subject that performed the activity.

#### read.data

Reads in all the 'test' and 'train' data using the functions above and then combines the two sets into a single data frame and returns it.

#### calc.averages

Calculates the averages of each measurement in `combined` for each subject/activity pair.
