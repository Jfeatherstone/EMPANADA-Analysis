import os
import pandas as pd
from moviepy.video.io.ffmpeg_tools import ffmpeg_extract_subclip

nameData = pd.read_excel('EMPANADA Data Files Key.xlsx')

# Names for conversion
originalNames = nameData['Original File Name:']
newNames = nameData['New File Name:']

# And the start and end times since we will be cropping here as well
# Because of the way the time is entered, datetime thinks that the seconds are actually
# minutes, so we use the minute attribute in the loop below
startTimes = nameData['Crop begin time:']
endTimes = nameData['Crop end time:']

for i in range(len(originalNames)):
    try:
        #os.rename(f'Cropped-{newNames[i]}', f'{newNames[i]}')
        ffmpeg_extract_subclip(originalNames[i], startTimes[i].minute, endTimes[i].minute, targetname=f'{newNames[i]}')
        print(f'Renamed and cropped file {originalNames[i]} to {newNames[i]}')
    except:
        print(f'Error processing {originalNames[i]}!')
