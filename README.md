# EMPANADA Data Analysis

## File Descriptions
---

Below is a list of all of the files contained in this repo, including what they do (or attempt to do) and what methods they use.

### Preprocessing

#### LoadFiles.m

This file organizes the data files based on their file name and loads them into a struct called trials. This struct includes information about the experiment parameters (speed, day, gravity), the full path of the file (might change soon), and an empty spot to put the analysis results later on.

The script assumes that all files are named using the convention `Day<#>-<Gravity>-<speed>mms.mkv` and that they are located in the directory defined by either of the startup files (see Misc section)

### Analysis

#### Brightness_GSquared_Analysis.m

This is currently the only analysis file that I have been using, and it calculates the average brightness for each frame of each movie, as well as the average G^2 value for each frame. The former is as simple as it sounds, while more information on the later can be found in references (1) and (2).

### Postprocessing

### Misc


## References
---

1. Karen E. Daniels, Jonathan E. Kollmer and James G. Puckett. “Photoelastic force measurements in granular materials.” Review of Scientific Instruments 88, 051808 (2017)
    - [Github repo](https://github.com/DanielsNonlinearLab/Gsquared)

