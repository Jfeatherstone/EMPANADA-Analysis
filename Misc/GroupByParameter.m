function groupedList = GroupByParameter(listOfItems, parameterValues)

if length(listOfItems) ~= length(parameterValues)
   fprintf('Dimension mismatch of input variables!')
   return
end

groupedList = containers.Map('KeyType', class(parameterValues), 'ValueType', class(listOfItems));

for i=1: length(listOfItems)
    if ~ismember(parameterValues(i), cell2mat(groupedList.keys))
       groupedList(parameterValues(i)) = listOfItems(i); 
    else
       disp(groupedList(parameterValues(i)));
       groupedList(parameterValues(i)) = [groupedList(parameterValues(i)), listOfItems(i)]; 
    end
end

end % Function end

