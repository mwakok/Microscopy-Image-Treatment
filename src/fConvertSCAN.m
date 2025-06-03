% Convert Metamorph .scan files to stack

function Stack = fConvertSCAN(PathName,Select,WL)

i=1;j=1;
for n = 1:length(Select)
   if ~isempty(strfind(Select{n},'.TIF')) && ~isempty(strfind(Select{n},WL{1}))
       Stack{1,1}{i} = imread([PathName Select{n}]);
       i=i+1;
   elseif ~isempty(strfind(Select{n},'.TIF')) && ~isempty(strfind(Select{n},WL{2}))
       Stack{1,2}{j} = imread([PathName Select{n}]);
       j=j+1;
   elseif ~isempty(strfind(Select{n},'.TIF'))
       Stack{1,1}{n} = imread([PathName Select{n}]);
   end
   progressbar([], n/length(Select))
end

% Remove stitched image
for n = 1 : length(Stack)
    Stack{1,n}(:,end) = [];
end

end

