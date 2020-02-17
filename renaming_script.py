import os
import pandas as pd

nameData = pd.read_excel('EMPANADA Data Files Key.xlsx')

originalNames = nameData['Original File Name:']
newNames = nameData['New File Name:']

for i in range(len(originalNames)):
    try:
        os.rename(f'{originalNames[i]}', f'{newNames[i]}')
        print(f'Renamed file {originalNames[i]} to {newNames[i]}')
    except:
        print(f'File {originalNames[i]} not found')
