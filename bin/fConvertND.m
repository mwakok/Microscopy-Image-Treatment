% Convert Metamorph .nd files to stack

function Stack = fConvertND(PathName,Select,WL)

k1=1;k2=1;k3=1;k4=1;

for n = 1:length(Select)
    
   % Find index of timepoint registration and ommit from comparison to wavelength 
   match = strfind(Select{n},'_t');
    
   if ~isempty(strfind(Select{n},'.TIF')) && sum(strcmp(WL,{'x'}) == 1)>0
       Stack{1,1}{n} = imread([PathName Select{n}]);    
   elseif ~isempty(strfind(Select{n},'.TIF')) && ~isempty(strfind(Select{n}(1:match(end)),WL{1}))
       Stack{1,1}{k1} = imread([PathName Select{n}]);
       k1=k1+1;
   elseif ~isempty(strfind(Select{n},'.TIF')) && ~isempty(strfind(Select{n}(1:match(end)),WL{2}))
       Stack{1,2}{k2} = imread([PathName Select{n}]);
       k2=k2+1;
   elseif ~isempty(strfind(Select{n},'.TIF')) && ~isempty(strfind(Select{n}(1:match(end)),WL{3}))
       Stack{1,3}{k3} = imread([PathName Select{n}]);
       k3=k3+1;
   elseif ~isempty(strfind(Select{n},'.TIF')) && ~isempty(strfind(Select{n}(1:match(end)),WL{4}))
       Stack{1,4}{k4} = imread([PathName Select{n}]);
       k4=k4+1;    
   elseif ~isempty(strfind(Select{n},'.TIF'))
       Stack{1,1}{n} = imread([PathName Select{n}]);
   end
%    progressbar([], n/length(Select))
end

end



