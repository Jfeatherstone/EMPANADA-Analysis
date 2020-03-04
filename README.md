# EMPANADA Data Analysis

## File Descriptions

Below is a list of all of the files contained in this repo, including what they do (or attempt to do) and what methods they use.

(Last updated 3-3-2020, so there may be changes to below, though I will try and update this whenever I can)

---
### Preprocessing/

#### LoadFiles.m

This file organizes the data files based on their file name and loads them into a struct called trials. This struct includes information about the experiment parameters (speed, day, gravity, crop times, validity of data), the name of the file, and an empty spot to put the analysis results later on.

The script assumes that all files are named using the convention `Day<#>-<Gravity>-<speed>mms.mkv` and that they are located in the directory defined by the startup file `startup.m`

Some other notes about this file:
- The spreadsheet located in the root directory contains several pieces of information about each trial that is read in during this preprocessing:
    - There is no reason to analyze the entire video, when we are really only interested in what happens as the probe descends. Because of this, I have marked when the probe descent begins and when it ends for each video, which is later used to limit the analysis to this subclip. This process of identifying when the probe is moving is done qualitatively right now ie. I just watch each video, but could be automated later on.
    - Some of the videos (especially micro gravity trials) have some very questionable gravity, and therefore have been marked as such and are ignored in this preprocessing. This includes any videos where several particles touch the top of the enclosure. These issues were caused by an unstable parabolic flight and/or turbulence.

---
### Analysis/

#### BrightnessAnalysis.m

##### Returned fields:
- `frameTime`
    - The time of each data point
- `averageBrightness`
    - The average brightness of the entire frame
- `averageBrightnessDerivative`
    - The derivative of the average brightness calculated using the central difference stencil (and forward/backward stencil for first/last points)

This analysis principally looks at the average brightness for each frame of each video. This analysis takes a very short amount of time, about 3 minutes for 25 trials as of now (on my laptop, GTX 1060, i7-8750H).

#### GSquaredAnalysis.m

##### Returned fields:
- `frameTime`
    - The time of each data point
- `averageGSquared`
    - The average G<sup>2</sup> value for each frame

This analysis looks at the gradient of the brightness for each frame, calculated using the G<sup>2</sup> method outlined in reference 1. This analysis takes a very long period of time, about 6 days for 26 trials (on onyx).

#### LocalizedBrightnessAnalysis.m

##### Returned fields:
- `frameTime`
    - The time of each data point
- `averageRowBrightness`
    - The average brightness per row of each frame
- `averageRowBrightnessDerivative`
    - The derivative of the average brightness per row of each frame calculated using the central difference stencil (and forward/backward stencil for first/last points)
- `averageColumnBrightness`
    - The average brightness per column of each frame
- `averageColumnBrightnessDerivative`
    - The derivative of the average brightness per column of each frame calculated using the central difference stencil (and forward/backward stencil for first/last points)

This analysis gives more information about where the brightness is changing through the insertion of the probe, and is currently being used to calculate and 'area of effect' of the probe as a function of speed and gravity.

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

