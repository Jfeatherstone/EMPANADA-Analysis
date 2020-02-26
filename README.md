# EMPANADA Data Analysis

## File Descriptions

Below is a list of all of the files contained in this repo, including what they do (or attempt to do) and what methods they use.

---
### Preprocessing

#### LoadFiles.m

This file organizes the data files based on their file name and loads them into a struct called trials. This struct includes information about the experiment parameters (speed, day, gravity), the full path of the file (might change soon), and an empty spot to put the analysis results later on.

The script assumes that all files are named using the convention `Day<#>-<Gravity>-<speed>mms.mkv` and that they are located in the directory defined by either of the startup files (see Misc section)

---
### Analysis

#### Brightness_GSquared_Analysis.m

This is currently the only analysis file that I have been using, and it calculates the average brightness for each frame of each movie, as well as the average G<sup>2</sup> value for each frame. The former is as simple as it sounds, while more information on the later can be found in reference (1) (code can be found there as well).

This takes in the `trials` struct that is created in `LoadFiles.m` and outputs the same struct to `AnalyzedData.mat` with the results appended as a field.

---
### Postprocessing

#### BrightnessPostprocessing.m

Defines the function brightnessPostProcessing(dataset) create 3 figures for each data set:
1. Plot of average brightness vs. time
2. Plot of average G<sup>2</sup> vs. time
3. Previous two plots overlayed (and normalized)

#### SpeedComparisonProcessing.m

Sorts all entries in `trials` into 3 categories based on their gravity ('Lunar'|'Martian'|'Micro') and then sorts based on the speed of the probe. Creates a total of 6 graphs, 2 for each value of gravity:
1. Comparison of all trials for that gravity; average brightness vs. time
2. Comparison of all trials for that gravity; average G<sup>2</sup> vs. time

#### RealTimeTrackingShow.m

Creates a real time comparison of the current values of average brightness and G<sup>2</sup> and the actual video frame in which the value is calculated from. Does not save anything to a file, and skips over as many frames as needed to keep up with real time.

For a smooth version of this, see `RealTimeTrackingSave.m`.

#### RealTimeTrackingSave.m

Creates a real time comparison of the current values of average brightness and G<sup>2</sup> and the actual video frame in which the value is calculated from. Saves each frame as an image and later compiles these into a video which is later to saved to the folder `Output.avi`.

For a quick and dirty version of this see `RealTimeTrackingShow.m`. As expected, takes much longer to run than the previously mentioned counterpart, since it goes over every frame.

#### CentralDifferenceProcessingIndividual.m

Uses the central difference discrete differentiation stencil to calculate the derivative of the average brightness with respect to time. Throws out the first and last point of each data set since the central difference stencil cannot be used.

This script produces 2 figures for each entry in `trials`:
1. A plot of d/dt(average brightness) vs. time
1. A plot of d/dt(average brightness)<sup>2</sup> vs. time

In the future, I will likely convert the actual stencil calculation into its own analysis file, that way the method can be used in other figures too.

---
### Misc

#### startup_laptop.m

A startup file that is run on my personal computer to initialize certain directory variables, as well as fonts for figures. I am not the original author of this file, so there are a few things I don't fully understand here, most of which I have commented out.

For equivalent on lab machines, see `startup_eno.m`.

#### startup_eno.m

A startup file that is run on lab machines to initialize certain directory variables, as well as fonts for figures. I am not the original author of this file, so there are a few things I don't fully understand here, most of which I have commented out.

For equivalent on my personal computer, see `startup_laptop.m`.

#### printfig.m

A script created to easily save figures to files in their specified folders as defined in the proper startup file.

## References

1. Karen E. Daniels, Jonathan E. Kollmer and James G. Puckett. “Photoelastic force measurements in granular materials.” Review of Scientific Instruments 88, 051808 (2017)
    - [Github repo](https://github.com/DanielsNonlinearLab/Gsquared)

