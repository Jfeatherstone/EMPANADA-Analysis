function downsampledData = AverageDownsample(data,binSize)

i = 1;
j = 1;
while i <= length(data)
   sampleWindow = data(i:min(i+binSize-1, length(data)));
   downsampledData(j) = mean(sampleWindow);
   i = i + binSize;
   j = j + 1;
end

end

