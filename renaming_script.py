import os
import pandas as pd
#from moviepy.video.io.ffmpeg_tools import ffmpeg_extract_subclip

nameData = pd.read_excel('EMPANADA Data Files Key.xlsx')

# Names for conversion
originalNames = nameData['Original File Name:']
newNames = nameData['New File Name:']

# We no longer crop the data here because it messes with the frame rate of the video later on
# This process is now done during the actual analysis process

for i in range(len(originalNames)):
    try:
        os.rename(originalNames[i]}, newNames[i])
        #ffmpeg_extract_subclip(originalNames[i], startTimes[i].minute, endTimes[i].minute, targetname=f'{newNames[i]}')
        print(f'Renamed file {originalNames[i]} to {newNames[i]}')
    except:
        print(f'Error processing {originalNames[i]}!')
