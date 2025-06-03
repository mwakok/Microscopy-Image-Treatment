% Image processing v6.2
% Description
% 1) FOV alignment (active)
% 2) Drift correction (active)
% 3) Wiener filter (active)
% 4) Wallis filter (inactive)
% 5) Background subtraction (active)
% 6) Bleach correction (inactive)
% 
% ToDo:
% - Handle more than two wavelenghts for the drift correction (fixed
% 29-08-2016)
% - Error in indexing the output files (fixed 29-08-2016)
% - Error in ND conversion for more that 3 wavelengths (fixed 05-03-2018)
% - Option to save processing details
% - Selection reference channel not working properly
% 
% Maurits Kok, 2018



function GUI
clearvars -global Stack StackInfo Config

addpath('src');

% Dialogue initialization

% Initialize the main GUI
hImageCor.fig = figure('Units','normalized','DockControls','off','IntegerHandle','off','Name','Image Correction - Select settings','MenuBar','none',...
                       'NumberTitle','off','OuterPosition',[0.35 0.35 0.3 0.4],'HandleVisibility','callback',...
                       'Visible','on','NextPlot','add');


% Checkboxes for select each function                    
hImageCor.tSelect = uicontrol('Parent',hImageCor.fig,'Style','text','String','Select image processing steps:',...
                              'Units','normalized','Position',[0.1 0.85 0.35 0.1],'HorizontalAlignment','left','FontSize',10);                              
hImageCor.bDist = uicontrol('Parent',hImageCor.fig,'Style','checkbox','Units','normalized','String',' 1) FOV alignment',...
                            'Position',[0.1 0.78 0.7 0.1],'Enable','on','FontSize',10,'HandleVisibility','off',...
                            'Value',1.0);
hImageCor.bDrift = uicontrol('Parent',hImageCor.fig,'Style','checkbox','Units','normalized','String',' 2) Drift removal',...
                             'Position',[0.1 0.68 0.7 0.1],'Enable','on','FontSize',10,'HandleVisibility','off',...
                             'Value',1.0);  
hImageCor.bWiener = uicontrol('Parent',hImageCor.fig,'Style','checkbox','Units','normalized','String',' 3) Wiener filter',...
                           'Position',[0.1 0.58 0.7 0.1],'Enable','on','FontSize',10,'HandleVisibility','off',...
                           'Value',0.0);
hImageCor.bWallis = uicontrol('Parent',hImageCor.fig,'Style','checkbox','Units','normalized','String',' 4) Wallis filter',...
                           'Position',[0.1 0.48 0.7 0.1],'Enable','on','FontSize',10,'HandleVisibility','off',...
                           'Value',0.0);                       
hImageCor.bBkg = uicontrol('Parent',hImageCor.fig,'Style','checkbox','Units','normalized','String',' 5) Background subtraction',...
                           'Position',[0.1 0.38 0.7 0.1],'Enable','on','FontSize',10,'HandleVisibility','off',...
                           'Value',0.0);
hImageCor.bBleach = uicontrol('Parent',hImageCor.fig,'Style','checkbox','Units','normalized','String',' 6) Photobleaching correction',...
                           'Position',[0.1 0.28 0.7 0.1],'Enable','off','FontSize',10,'HandleVisibility','off',...
                           'Value',0.0);

% Checkboxes for select to save the output of each function                          
hImageCor.tOutput = uicontrol('Parent',hImageCor.fig,'Style','text','String','Save Output?',...
                              'Units','normalized','Position',[0.65 0.85 0.3 0.1],'HorizontalAlignment','left','FontSize',10);
hImageCor.bDistSave = uicontrol('Parent',hImageCor.fig,'Style','checkbox','Units','normalized',...
                                 'Position',[0.7 0.78 0.1 0.1],'Enable','on','Value',0.0);
hImageCor.bDriftSave = uicontrol('Parent',hImageCor.fig,'Style','checkbox','Units','normalized',...
                                 'Position',[0.7 0.68 0.1 0.1],'Enable','on','Value',1.0);             
hImageCor.bWienerSave = uicontrol('Parent',hImageCor.fig,'Style','checkbox','Units','normalized',...
                                 'Position',[0.7 0.58 0.1 0.1],'Enable','on','Value',0.0);                             
hImageCor.bWallisSave = uicontrol('Parent',hImageCor.fig,'Style','checkbox','Units','normalized',...
                                 'Position',[0.7 0.48 0.1 0.1],'Enable','on','Value',0.0);
hImageCor.bBkgSave = uicontrol('Parent',hImageCor.fig,'Style','checkbox','Units','normalized',...
                                 'Position',[0.7 0.38 0.1 0.1],'Enable','on','Value',0.0);                                          
hImageCor.bBleachSave = uicontrol('Parent',hImageCor.fig,'Style','checkbox','Units','normalized',...
                                 'Position',[0.7 0.28 0.1 0.1],'Enable','off','Value',0.0);                             

% Continue and Cancel buttons                             
hImageCor.bContinue = uicontrol('Parent',hImageCor.fig,'Style','togglebutton','String','OK','Units','normalized',...
                          'Position',[0.2 0.15 0.2 0.1],'FontSize',10,'CallBack',@Options);
hImageCor.bCancel = uicontrol('Parent',hImageCor.fig,'Style','togglebutton','String','Cancel','Units','normalized',...
                          'Position',[0.6 0.15 0.2 0.1],'FontSize',10,'CallBack',@Close);
                        
set(hImageCor.fig,'CloseRequestFcn',@Close);

setappdata(0,'hImageCor',hImageCor);
end                      

function Options(~,~)
global Config
hImageCor = getappdata(0,'hImageCor');
set(hImageCor.fig,'Visible','off');

% Retrieve the image treatment selection
Config.Settings(1) = get(hImageCor.bDist,'Value');
Config.Settings(2) = get(hImageCor.bDrift,'Value');
Config.Settings(3) = get(hImageCor.bWiener,'Value');
Config.Settings(4) = get(hImageCor.bWallis,'Value');
Config.Settings(5) = get(hImageCor.bBkg,'Value');
Config.Settings(6) = get(hImageCor.bBleach,'Value');

% Warning if no functions were selected
if sum(Config.Settings(:)) == 0
    string = 'No image treatment was selected';
    Completion(string);
end

% Retrieve the saving options
Config.Output(1) = get(hImageCor.bDistSave,'Value');
Config.Output(2) = get(hImageCor.bDriftSave,'Value');
Config.Output(3) = get(hImageCor.bWienerSave,'Value');
Config.Output(4) = get(hImageCor.bWallisSave,'Value');
Config.Output(5) = get(hImageCor.bBkgSave,'Value');
Config.Output(6) = get(hImageCor.bBleachSave,'Value');


set(hImageCor.fig,'Visible','off');

hImageCor.Options = figure('Units','normalized','DockControls','off','IntegerHandle','off','Name','Image Correction - Select settings','MenuBar','none',...
                       'NumberTitle','off','OuterPosition',[0.35 0.35 0.3 0.4],'HandleVisibility','callback',...
                       'Visible','on','NextPlot','add');
                   
hImageCor.t1 = uicontrol('Parent',hImageCor.Options,'Style','text','String','Assign channel names','Units','normalized',...
                         'Position',[0.1 0.8 0.3 0.1],'HorizontalAlignment','left','FontSize',10);                     
hImageCor.t2 = uicontrol('Parent',hImageCor.Options,'Style','text','String','Additional settings','Units','normalized',...
                         'Position',[0.1 0.5 0.3 0.1],'HorizontalAlignment','left','FontSize',10);                     

hImageCor.tDist = uicontrol('Parent',hImageCor.Options,'Style','text','String','Select misaligned FOV:','Units','normalized',...
                            'Position',[0.1 0.7 0.3 0.1],'HorizontalAlignment','left','FontSize',8);
hImageCor.lDist = uicontrol('Parent',hImageCor.Options,'Style','popup','String',{'w1', 'w2', 'w3', 'w4', '405', '488', '561','642'},'Units','normalized',...
                            'Position', [0.4 0.71 0.15 0.1],'FontSize',8);
set(hImageCor.lDist,'Value',6);

hImageCor.tDefaultCal = uicontrol('Parent',hImageCor.Options,'Style','text','String','Use default calibration?','Units','normalized',...
                            'Position',[0.6 0.7 0.3 0.1],'HorizontalAlignment','left','FontSize',8);
hImageCor.bDefaultCal = uicontrol('Parent',hImageCor.Options,'Style','checkbox','Units','normalized',...
                                 'Position',[0.85 0.74 0.1 0.1],'Enable','on','Value',0.0);                          
                        
hImageCor.tDrift = uicontrol('Parent',hImageCor.Options,'Style','text','String','Select drift reference channel:','Units','normalized',...
                            'Position',[0.1 0.6 0.3 0.1],'HorizontalAlignment','left','FontSize',8);                        
hImageCor.lDrift = uicontrol('Parent',hImageCor.Options,'Style','popup','String',{'[all]', 'w1', 'w2', 'w3', 'w4', '405', '488','561','642'},'Units','normalized',...
                            'Position', [0.4 0.61 0.15 0.1],'FontSize',8);
set(hImageCor.lDrift,'Value',8);                      

hImageCor.tBkgOptions = uicontrol('Parent',hImageCor.Options,'Style','text','String','Select background correction shape:','Units','normalized',...
                                  'Position',[0.1 0.4 0.3 0.1],'HorizontalAlignment','left','FontSize',8);
hImageCor.lBkgOptions = uicontrol('Parent', hImageCor.Options,'Style','popup','String',{'disk','rectangle','square'},...
                                  'Units','normalized','Position',[0.4 0.4 0.15 0.1],'FontSize',8);
set(hImageCor.lBkgOptions,'Value',3);                              
                              
hImageCor.tBkgSize = uicontrol('Parent',hImageCor.Options,'Style','text','String','Select correction size:','Units','normalized',...
                               'Position',[0.1 0.3 0.3 0.1],'HorizontalAlignment','left','FontSize',8);
hImageCor.eBkgSize = uicontrol('Parent',hImageCor.Options,'Style','edit','String','15','Units','normalized','Enable','on',...
                               'Position', [0.4 0.36 0.05 0.05],'FontSize',8);

hImageCor.tParallel = uicontrol('Parent',hImageCor.Options,'Style','text','String','Use multiple CPUs?','Units','normalized',...
                               'Position',[0.1 0.2 0.3 0.1],'HorizontalAlignment','left','FontSize',8);                           
hImageCor.bParallel = uicontrol('Parent',hImageCor.Options,'Style','checkbox','Units','normalized',...
                                 'Position',[0.4 0.24 0.1 0.1],'Enable','on','Value',0.0);                           
                                                      
hImageCor.Continue = uicontrol('Parent',hImageCor.Options,'Style','togglebutton','String','Continue','Units','normalized',...
                           'Position',[0.6 0.1 0.3 0.1],'FontSize',10,'CallBack',@Continue);

%% Enable options according to treatment selection                       
if Config.Settings(1) == 0 % Disable options for FOV alignment if not necessary
    set(hImageCor.lDist,'Enable','off');
    set(hImageCor.bDefaultCal,'Enable','off');
end
if Config.Settings(2) == 0 % Disable options for Drift correction if not necessary
    set(hImageCor.lDrift,'Enable','off');
end
if Config.Settings(5) == 0 % Disable options for Background subtraction of not necessary
    set(hImageCor.lBkgOptions,'Enable','off');
    set(hImageCor.eBkgSize,'Enable','off');
end

setappdata(0,'hImageCor',hImageCor);
end

function Close(~,~)
% Close all figures and delete variables

% hImageCor = getappdata(0,'hImageCor');
% delete(hImageCor.fig);
warning off
clearvars -global Stack StackInfo Config
clearvars

close all

% rmappdata(0,'hImageCor');
end

function Completion(string,~)
% Question dialog for continuation
close all

choice = questdlg(string,...
                  'Finished',...
                  'Continue','Close','Close');

% Handle response
switch choice
    case 'Continue'
        GUI;
    case 'Close'
        Close;
end
end

function Continue(~,~)
global Stack Config StackInfo;

hImageCor = getappdata(0,'hImageCor');

%% Initialize parallel CPU pool

set(hImageCor.Options,'Visible','off');

h = msgbox('Initializing parallel processing...');

p = gcp('nocreate');
if get(hImageCor.bParallel,'Value') == 1 && ~isempty(p)
%     delete(gcp('nocreate'));
%     defaultProfile = parallel.defaultClusterProfile;
%     myCluster = parcluster(defaultProfile);
%     parpool(myCluster);
    Config.CPU = 1;
elseif get(hImageCor.bParallel,'Value') == 1 && isempty(p)
    defaultProfile = parallel.defaultClusterProfile;
    myCluster = parcluster(defaultProfile);
    parpool(myCluster);
    Config.CPU = 1;
else
    Config.CPU = 0;
end

close(h);

%% Retrieve Values from GUI
Bkglist = get(hImageCor.lBkgOptions,'String');
Config.BkgShape = Bkglist(get(hImageCor.lBkgOptions,'Value'));
Config.BkgSize = get(hImageCor.eBkgSize,'String');

Config.WaveLengths = get(hImageCor.lDist,'String');
if get(hImageCor.bDist,'Value') == 1
    Config.Distwl = Config.WaveLengths(get(hImageCor.lDist,'Value'));
else
    Config.Distwl = [];
end

Config.WaveLengths = get(hImageCor.lDrift,'String');
if get(hImageCor.bDrift,'Value') == 1
    Config.Driftwl = Config.WaveLengths(get(hImageCor.lDrift,'Value'));
else
    Config.Driftwl = [];
end

if isempty(Config.Distwl) && isempty(Config.Driftwl)
   Config.WaveLengths = {'w1','w2','w3','w4'}; % default
elseif sum(strcmp(Config.Distwl,{'w1','w2','w3','w4'})) > 0 || sum(strcmp(Config.Driftwl,{'w1','w2','w3','w4'})) > 0
    Config.WaveLengths = {'w1','w2','w3','w4'};
elseif sum(strcmp(Config.Driftwl,{'[all]'})) > 0 % Single wavelength acquisition 
    Config.WaveLengths = {'[all]'};
elseif sum(strcmp(Config.Distwl,{'405','488','561','642'})) > 0 || sum(strcmp(Config.Driftwl,{'405','488','561','642'})) > 0
    Config.WaveLengths = {'405','488','561','642'};
end


%% Import stacks
HomeFolder = 'L:\BN\MDO\Shared\Vladimir\exp\nanospring\180301 NS-T1S3 and Ska-P\ch1 1nM Ska-P';
% HomeFolder = 'C:\';
[FileName, PathName] = uigetfile('*','Load image stacks','MultiSelect','on',...
                                 HomeFolder);

% Check stacks                                                          
if isequal(FileName,0) || isequal(PathName,0)
    string = 'No files were found';
    Completion(string);
end

if ~iscell(FileName)
    FileName = {FileName};
end

Config.FileName = FileName;
Config.PathName = PathName;

Index;
if Config.Settings(1) == 1
    mode = get(hImageCor.bDefaultCal,'Value');
    Dist_Index(mode);
end
if Config.Settings(2) == 1
    Drift_Index;
end

%% Create Loading Order
if Config.Settings(2) == 1 && size(Config.Index,2) == 7
    Config.Load = unique([Config.Index{:,7}]);
    list = find(cellfun('isempty',Config.Index(:,7)));
    if ~isempty(list)
        for i = 1 : length(list)
            Config.Load(end+1) = max(Config.Load) + 1;
        end
        EM = 1;
    end
else
    Config.Load = 1:1:length(Config.FileName);
end


%% Initialize progress bar
String = {'Total progress', 'Loading Stack','1) FOV alignment', '2) Drift correction', '3) Wiener filter',...
          '4) Wallis filter', '5) Background subtraction', '6) Bleach correction', 'Saving stack'};
PBstring = String(1:2);
for i = 1 : length(Config.Settings)
   if Config.Settings(i) == 1
       PBstring{end+1} = String{i+2};
   end
end
if sum(Config.Output) > 0
    PBstring{end+1} = String{end};
end
progressbar(PBstring{:})
% Config.Status = zeros(1,length(PBstring));
Config.Status = cell(1,length(PBstring));
Config.Status(:) = {0};


%% Load Stacks
for IDX = 1 : length(Config.Load)
    
    Config.SaveName = [];
    Config.Status_Count = 3;
    Config.Debug = IDX;
    
    % Check which files are part of the current load number
    if size(Config.Index,2) == 7
        idx = [];
        for i = 1:numel(Config.Index(:,7))
           test = Config.Index{i,7} == Config.Load(IDX);
           if ~isempty(test) && test == 1
               idx = [idx i];
           end
        end
        if isempty(idx)
            idx = list(EM);
            EM = EM + 1;
        end
    else
        idx = Config.Load(IDX); 
    end
    
    % Load and convert MetaMorph .ND files
    if ~isempty(strfind(Config.FileName{1,idx(1)},'.nd')) && length(idx) == 1
        
%         if Config.Index{idx,4} == 1
%             Convert(idx,1);
%         elseif Config.Index{idx,4} == 0
%             Convert(idx,0);
%         end
        
        Config.Index{idx,4} = 0;
        Convert(idx);
        
        if size(Stack,2) == 1 && Config.Index{idx,4} == 1
            Config.SaveName{1} = strrep(Config.FileName{1,idx},'.nd',strcat('_',Config.WaveLengths{1},'.tif'));
            Config.SaveName{2} = strrep(Config.FileName{1,idx},'.nd',strcat('_',Config.WaveLengths{2},'.tif'));
        elseif size(Stack,2) == 1 && Config.Index{idx,4} == 0
            Config.SaveName{1} = strrep(Config.FileName{1,idx},'.nd','.tif');
        elseif size(Stack,2) > 1
            for j = 1 : size(Stack,2)
                Config.SaveName{j} = strrep(Config.FileName{1,idx},'.nd',strcat('_',Config.WaveLengths{j},'.tif'));
            end
        end
    % Load and convert MetaMorph .SCAN files   
    elseif ~isempty(strfind(Config.FileName{1,idx(1)},'.scan')) && length(idx) == 1
        
%         if Config.Index{idx,4} == 1
%             Convert(idx,1);
%         elseif Config.Index{idx,4} == 0
%             Convert(idx,0);
%         end
        
        Config.Index{idx,4} = 0;
        Convert(idx);
            
        if size(Stack,2) == 1 && Config.Index{idx,4} == 1
            Config.SaveName{1} = strrep(Config.FileName{1,idx},'.scan',strcat('_',Config.WaveLengths{1},'.tif'));
            Config.SaveName{2} = strrep(Config.FileName{1,idx},'.scan',strcat('_',Config.WaveLengths{2},'.tif'));
        elseif size(Stack,2) == 1
            Config.SaveName{1} = strrep(Config.FileName{1,idx},'.scan','.tif');
        elseif size(Stack,2) == 2
            Config.SaveName{1} = strrep(Config.FileName{1,idx},'.scan',strcat('_',Config.WaveLengths{1},'.tif'));
            Config.SaveName{2} = strrep(Config.FileName{1,idx},'.scan',strcat('_',Config.WaveLengths{2},'.tif'));
        end
    
    % Ignore files that do not require any correction
    elseif length(idx) == 1 && sum(cellfun('isempty',Config.Index(idx(1),2:3))) == 0 && sum(Config.Settings(3:end)) == 0
        Stack = [];
    % Load .TIF and .STK stacks
    elseif sum(sum(~cellfun('isempty',Config.Index(idx(1:end),2:3)))) > 0 || sum(Config.Settings(3:end)) > 0
        for n = 1 : length(idx)
            source = [Config.PathName Config.FileName{1,idx(n)}];
            if ~isempty(strfind(Config.FileName{1,idx(n)},'.tif')) || ~isempty(strfind(Config.FileName{1,idx(n)},'.tiff')) || ~isempty(strfind(Config.FileName{1,idx(n)},'.TIF'))
%                 [Stack{1,n},~,~] = fStackRead2(source,1);
                t_Stack = tiffread2(source);                
                for m = 1 : length(t_Stack)
                    [Stack{1,n}{1,m}] = double(t_Stack(m).data);
                end
                Config.SaveName{1,n} = Config.FileName{1,idx(n)};
            elseif ~isempty(strfind(Config.FileName{1,idx(n)},'.stk'))
                [Stack{1,n},StackInfo,~] = fStackRead2(source,1);                
                Config.SaveName{1,n} = Config.FileName{1,idx(n)};
            end
        end
        
        % Update progressbar
        Config.Status{2} = 1;        
    end
Config.Status{1} = Config.Status{1} + ((1/(length(Config.Status)-1))/length(Config.Load));
progressbar(Config.Status{:});

%% 1) Distortion correction
% if Config.Settings(1) == 1 && IDX == 1
%     mode = get(hImageCor.bDefaultCal,'Value');
%     Dist_Index(mode);
% end

if Config.Settings(1) == 1 && sum([Config.Index{idx,5}]) > 0
   Distortion(idx);
   Config.Status{1} = Config.Status{1} + ((1/(length(Config.Status)-1))/length(Config.Load));
   progressbar(Config.Status{:});
elseif Config.Settings(1) == 1 && sum([Config.Index{idx,5}]) == 0
    Config.Status{Config.Status_Count} = 1;
    Config.Status_Count =  Config.Status_Count + 1;
    Config.Status{1} = Config.Status{1} + ((1/(length(Config.Status)-1))/length(Config.Load));
    progressbar(Config.Status{:});
end

%% 2) Drift correction
if Config.Settings(2) == 1
    Drift_Index;
end

if Config.Settings(2) == 1 && sum([Config.Index{idx,6}]) > 0
    Drift(idx);
    Config.Status{1} = Config.Status{1} + ((1/(length(Config.Status)-1))/length(Config.Load));
    progressbar(Config.Status{:});
% elseif Config.Settings(2) == 1 && sum([Config.Index{idx,6}]) == 0 && ~isempty(strfind(Config.FileName{1,idx(1)},'.nd'))
%     Drift(idx);
%     Config.Status{1} = Config.Status{1} + ((1/(length(Config.Status)-1))/length(Config.Load));
%     progressbar(Config.Status{:});
elseif Config.Settings(2) == 1 && sum([Config.Index{idx,6}]) == 0
    Config.Status{Config.Status_Count} = 1;
    Config.Status_Count =  Config.Status_Count + 1;
    Config.Status{1} = Config.Status{1} + ((1/(length(Config.Status)-1))/length(Config.Load));
    progressbar(Config.Status{:});
end

%% 3) Wiener filter
if Config.Settings(3) == 1
    method = 1;
    Wiener(method);
    Config.Status{1} = Config.Status{1} + ((1/(length(Config.Status)-1))/length(Config.Load));
    progressbar(Config.Status{:});
end

%% 4) Wallis filter
if Config.Settings(4) == 1
    Parameter = [127 60 0.9 0.9]; %Add input to options
    Wallis(Parameter);
    Config.Status{1} = Config.Status{1} + ((1/(length(Config.Status)-1))/length(Config.Load));
    progressbar(Config.Status{:});
end

%% 5) Background correction
if Config.Settings(5) == 1
    Background;
    Config.Status{1} = Config.Status{1} + ((1/(length(Config.Status)-1))/length(Config.Load));
    progressbar(Config.Status{:});
end

%% 6) Bleach correction
if Config.Settings(6) == 1
    Bleach;
    Config.Status{1} = Config.Status{1} + ((1/(length(Config.Status)-1))/length(Config.Load));
    progressbar(Config.Status{:});
end

%% Export stacks
Config.number = '';
for n = 1 : length(Config.Output)
    if size(Stack,1) == 1
%          Export(1);
    elseif Config.Output(n) == 1 && size(Stack,1) >= n+1
%         temp = find(Config.Settings(1:n)==1);
        temp = find(~cellfun(@isempty,Stack(2:end,1)));
        string = char(0);
        for j = 1 : length(temp)
           string = strcat(string,num2str(temp(j)),'_');
        end
        Export(n+1,string);          
    end
end
% Stack = [];

% Save default calibration files if used
if Config.Settings(1) == 1 && get(hImageCor.bDefaultCal,'Value')==1
    SaveFolder = strcat(Config.PathName,'\','Output\Calibration\');
    file = [SaveFolder Config.BeadName{1}];
    imwrite(Config.Beads{1},file,'tiff','Compression','none','WriteMode','overwrite');
    file = [SaveFolder Config.BeadName{2}];
    imwrite(Config.Beads{2},file,'tiff','Compression','none','WriteMode','overwrite'); 
end

% Save processing details
% - drift correction
% - FOV alignment
% - background subtracting mask
% - 

Config.Status{1} = Config.Status{1} + ((1/(length(Config.Status)-1))/length(Config.Load));
Config.Status(2:end) = {0};
progressbar(Config.Status{:});

end
Config.Status{1} = 1;
progressbar(Config.Status{:});

string = 'Image treatment completed';
Completion(string);
end

function Index(~,~)
global Config

list = dir(Config.PathName);
list_name = {list.name};
list_bytes= {list.bytes};

[~,I] = sort({list.date});
Config.filelist = list_name(I);
Config.filelist_size = list_bytes(I);

for k = 1 : length(Config.FileName)
    
    if ~isempty(strfind(Config.FileName{k},'.nd'))
        match = strrep(Config.FileName{k},'.nd','');
        Selection = strfind(Config.filelist,match);
        i=1;
        for n = 1 : length(Selection)
           if ~isempty(Selection{n})
               preSelect{1,k}{i} = Config.filelist{n}; % selection of files to be converted
               Size{k}{i} = Config.filelist_size{n};
               i=i+1;
           end         
        end
        
        % Remove .nd file from list
        num = find(~cellfun(@isempty,strfind(preSelect{1,k},'.nd')));
        preSelect{1,k}(:,num) = [];
        
        % Check proper selection
        
        Selection2 = cell(1,length(preSelect{1,k}));
        Select{1,k} = cell(1);
        Size{k}(:,num) = [];
        
        for n = 1 : length(preSelect{1,k})
           position = strfind(preSelect{1,k}{1,n},'_');
           if strcmp(preSelect{1,k}{1,n}(1:position(end-1)-1),match) == 1
               Select{1,k}{1,end+1} = preSelect{1,k}{1,n};
           end
           if isempty(Select{1,k}{1,1})
               Select{1,k}(:,1) = [];
           end 
        end
        
        % Check whether selection is in correct time order
        time_points = zeros(1,length(Select{1,k}));

        for j = 1 : length(Select{k})
            time_points(1,j) = str2double(Select{1,k}{j}(strfind(Select{1,k}{j},'_t')+2:end-4));
        end

        [~,J] = sort(time_points);
        Select{1,k} = Select{1,k}(J);
        
        
%         % Check if files contain dual image
%         if sum(cellfun(@(x) x<1E6,Size{k})) == length(Size{k})
%             Dual = 0;
%         elseif sum(cellfun(@(x) x>1E6,Size{k})) == length(Size{k})
%             Dual = 1;
%         else
%             % Warning message
%         end
        
    elseif ~isempty(strfind(Config.FileName{k},'.scan'))
        match = strrep(Config.FileName{k},'.scan','');
        Selection = strfind(Config.filelist,match);
        i=1;
        for n = 1 : length(Selection)
           if ~isempty(Selection{n})
               Select{k}{i} = Config.filelist{n}; % selection of files to be converted
               Size{k}{i} = Config.filelist_size{n};
               i=i+1;
           end         
        end
        
         % Remove .scan file from list
        num = find(~cellfun(@isempty,strfind(Select{k},'.scan')));
        Select{k}(:,num) = [];
        Size{k}(:,num) = [];
        
        % Check if files contain dual image
        if sum(cellfun(@(x) x<1E6,Size{k})) == length(Size{k})-1
            Dual = 0;
        elseif sum(cellfun(@(x) x>1E6,Size{k})) == length(Size{k})-1
            Dual = 1;
        else
            % Warning message
        end
        
    elseif ~isempty(strfind(Config.FileName{k},'.stk'))
        match = strrep(Config.FileName{k},'.stk','');
        Select{k} = Config.FileName(k); % File is a tiff stack
        % Dual image detection not present
        Dual = 0;
        
    else
        match = strrep(Config.FileName{k},'.tif','');
        Select{k} = Config.FileName(k); % File is a tiff stack
        % Dual image detection not present
        Dual = 0;
    end
    count = cell(1,2);
    
    if Config.Settings(1) == 1 % If FOV alignment is required
       if find(~cellfun(@isempty,(strfind(Select{1,k},Config.Distwl{1})))) 
           count{1} = Config.Distwl{1};
       else
           count{1} = [];
       end
       Config.Index{k,1} = match;
       Config.Index{k,2} = count{1};
    end
    
    if Config.Settings(2) == 1 % If drift correction is required     
        if ~isempty(strfind(Config.Driftwl{1},'all'))
            count{2} = Config.Driftwl{1};
        elseif find(~cellfun(@isempty,(strfind(Select{1,k},Config.Driftwl{1})))) 
            count{2} = Config.Driftwl{1};
        else
            count{2} = [];
        end
        Config.Index{k,1} = match;
        Config.Index{k,3} = count{2};
    end
           
    if Config.Settings(1)~= 1 && Config.Settings(2)~=1
       Config.Index{k,3} = []; 
    end
    
    % Save dual image selection
%     if Dual == 1
%         Config.Index{k,2} = 'w1';
%         Config.Index{k,3} = 'w2';
%         Config.Index{k,4} = 1;
%     else
%         Config.Index{k,4} = 0;
%     end
    
    Config.Selection = Select;

end
end

function Dist_Index(mode,~)
global Config

if mode == 1
    
    Config.BeadName{1} = 'CAL_w1.tif';
    Config.BeadName{2} = 'CAL_w2.tif';
    
    Config.DistCal = find(~cellfun(@isempty,strfind(Config.BeadName,Config.Distwl{1})));
    for n = 1 : size(Config.Index,1)
        idx = find(strcmp(Config.Index(n,:), Config.Distwl{1}));
        if ~isempty(idx)
            Config.Index{n,5} = idx;
        else
            Config.Index{n,5} = 0;
        end
    end
    
%     PathName = 'C:\Program Files\Image_Treatment\application\';
    Config.Beads{1} = fStackRead2(Config.BeadName{1},0);
    Config.Beads{2} = fStackRead2(Config.BeadName{2},0);
    
elseif mode == 0
    
    [BeadName, BeadPath] = uigetfile('*','Select bead-calibration images','MultiSelect','on',...
                                     Config.PathName);

    if ~iscell(BeadName)
        BeadName = {BeadName};
    end
    
    Config.BeadPath = BeadPath;
    Config.BeadName = BeadName;
    
    % Check whether wavelength is present in BeadNames
    Config.DistCal = find(~cellfun(@isempty,strfind(Config.BeadName,Config.Distwl{1})));
    % Find corresponding stacks that need the distortion correction
    if ~isempty(Config.DistCal)
        for n = 1 : size(Config.Index,1)
            idx = find(strcmp(Config.Index(n,:), Config.Distwl{1}));
           if ~isempty(idx)
               Config.Index{n,5} = idx;
           else
               Config.Index{n,5} = 0;
           end
        end
    elseif isempty(Config.DistCal) && length(Config.BeadName) == 2
%         Config.DistCal = listdlg('PromptString','Select the distorted bead image',...
%                              'SelectionMode','single',...
%                              'ListString',Config.BeadName);
    %     Config.DistSelection = listdlg('PromptString','Select the distorted stacks',...
    %                          'SelectionMode','multiple',...
    %                          'ListString',Config.FileName);                 

    else
        warndlg('Please select two calibration images','Try again...');
        return
    end
    
    Config.Beads{1} = fStackRead2([Config.BeadPath Config.BeadName{1}],0);
    Config.Beads{2} = fStackRead2([Config.BeadPath Config.BeadName{2}],0);
    
end    

end

function Drift_Index(~,~)
%% Select files for Drift correction
global Config

    if ~isempty(Config.Driftwl)
        for n = 1: size(Config.Index,1)
            ref = find(strcmp(Config.Index(n,:), Config.Driftwl)); % Find reference files
           if ~isempty(ref)
               Config.Index{n,6} = ref;
           else
               Config.Index{n,6} = 0;
           end
        end
    end
    
%     if isempty(Config.Index{:,6})
%         Config.DriftRef = listdlg('PromptString','Select the reference stacks for drift correction',...
%                         'SelectionMode','multiple',...
%                         'ListString',Config.FileName);   
%     end
    
    
    % Match the files to be drift corrected    
    index = Config.Index;
    j=1;
    for k = 1 : size(index,1)
        if index{k,6} > 0
                 
           if ~isempty(index{k,2}) && ~isempty(index{k,3})
              Config.Index{k,7} = j;
              j = j+1;
           elseif ~isempty(index{k,2}) || ~isempty(index{k,3})
               wl1 = find((strcmp(Config.WaveLengths,index{k,index{k,6}})));
               wl2 = find(not((strcmp(Config.WaveLengths,index{k,index{k,6}}))));
               
               if ~isempty(strfind(index(k,1),Config.WaveLengths{wl1}))
                                                 
                   for i = 1 : length(wl2)                  
                       match = strrep(index{k,1},index{k,index{k,6}}, Config.WaveLengths{wl2(i)});                                   
                       idx = find(strcmp(index(:,1),match));
                       if ~isempty(idx)
                           Config.Index{k,7} = j;
                           Config.Index{idx,7} = j;
                           idx = [];
%                            j=j+1;
                       end
                   end   
                   j=j+1; 
               elseif strcmp(index(k,1),Config.WaveLengths{wl1}) == 0
                       Config.Index{k,7} = j;
                       j = j+1;
               end
                   
           end
           
       end
    end 
end

function CheckParameters(~,~)
global StackInfo Config

    if StackInfo.XCalibration ~= Config.Pixel
        PixelSize = questdlg(strcat('Would you like to replace the pixel size of',{' '},num2str(Config.Pixel),...
            ' to',{' '},num2str(StackInfo.XCalibration*1000)),...
            'Pixelsize Input Error',...
            'Yes','No','Yes');
        
        switch PixelSize,
        case 'Yes',
            Config.Pixel = StackInfo.XCalibration*1000;
        case 'No',
        end
        
    end

    Config.FrameTime = mean(diff(StackInfo.CreationTime));
    Config.FrameTimeStd = std(diff(StackInfo.CreationTime));
    
    if Config.FrameTime ~= Config.Time;
        FrameTime = questdlg(strcat('Would you like to replace the frametime of',{' '},num2str(Config.Time),...
            ' to',{' '},num2str(uint16(Config.FrameTime))),...
            'Frametime Input Error',...
            'Yes','No','Yes');
        
        switch FrameTime,
        case 'Yes',
            Config.Time = uint16(Config.FrameTime);
        case 'No',
        end
    end       
end

function Convert(IDX,~)
global Stack Config 

    if ~isempty(strfind(Config.FileName{1,IDX},'.nd'))
        Config.Convert = 1;
        tempStack = fConvertND(Config.PathName,Config.Selection{1,IDX},Config.WaveLengths);
        Config.Status{2} = 1;
        progressbar(Config.Status{:});
         
        
        % Only select non-empty cells
        Config.WaveLengths = Config.WaveLengths(~cellfun(@isempty, tempStack));
        tempStack = tempStack(~cellfun(@isempty, tempStack));        
        for n = 1 : length(tempStack)
            Stack{1,n} = tempStack{n};            
        end
        
%         if length(tempStack) == 2          
%             Stack{1,1} = tempStack{1};
%             Stack{1,2} = tempStack{2};       
%         elseif length(tempStack) == 1
%             Stack{1,1} = tempStack{1};
%         end
        
    elseif ~isempty(strfind(Config.FileName{1,IDX},'.scan'))
        Config.Convert = 1;
        tempStack = fConvertSCAN(Config.PathName,Config.Selection{IDX},Config.WaveLengths);    
        Config.Status{2} = 1;
        progressbar(Config.Status{:});
        if length(tempStack) == 2          
            Stack{1,1} = tempStack{1};
            Stack{1,2} = tempStack{2};                  
        elseif length(tempStack) == 1
            Stack{1,1} = tempStack{1};
        end
    end

% Check if image needs to be split
% if mode == 1
%     tempStack1 = cell(1,size(Stack{1,1},2));
%     tempStack2 = cell(1,size(Stack{1,1},2));
%    [~,y] = size(Stack{1,1}{1});
%    if y == 1024
%        for n = 1 : size(Stack{1,1},2)
%           tempStack1{1,n} = Stack{1,1}{n}(1:512,1:512); % Channel w1
%           tempStack2{1,n} = Stack{1,1}{n}(1:512,513:1024); % Channel w2
%        end
%    Stack{1,1} = tempStack1;
%    Stack{1,2} = tempStack2;
%    end
% end    
    
% if size(Stack{1}{1},2)/size(Stack{1}{1},1) == 1
%     mode = 0;       
% elseif size(Stack{1}{1},2)/size(Stack{1}{1},1) == 2
%     mode = 1;
% else 
%     mode = 0;
% end

mode = 0;

if mode == 1
    tempStack1 = cell(1,size(Stack{1,1},2));
    tempStack2 = cell(1,size(Stack{1,1},2));
   [~,y] = size(Stack{1,1}{1});

   for n = 1 : size(Stack{1,1},2)
      tempStack1{1,n} = Stack{1,1}{n}(1:y/2,1:y/2); % Channel w1
      tempStack2{1,n} = Stack{1,1}{n}(1:y/2,y/2+1:y); % Channel w2
   end
   Stack{1,1} = tempStack1;
   Stack{1,2} = tempStack2;
   
   Config.Index{IDX,2} = 'w1';
   Config.Index{IDX,3} = 'w2';
   Config.Index{IDX,4} = 1;
  
end    

end

function Distortion(idx,~)
global Stack Config

if Config.DistCal == 1
    Image_Dist = Config.Beads{1};
    Image_Norm = Config.Beads{2};
elseif Config.DistCal == 2
    Image_Dist = Config.Beads{2};
    Image_Norm = Config.Beads{1};
else 
    return
end


num = size(Image_Dist,2);
for n = 1 : num

% Bandpass filter to supress pixel noise and long-wavelength image
% variations 

    Config.bpass{1,n} = bpass(Image_Norm{n},1,11);
    Config.bpass{2,n} = bpass(Image_Dist{n},1,11);

    % Pre-process the images with a cross correlation-based drift correction 
    % before finding the peaks

    Result = dftregistration(fft2(Config.bpass{1,1}), fft2(Config.bpass{2,1}), 100);
    Config.bpass{3,n} = imtranslate(Config.bpass{2,n}, [Result(3) Result(4)]);

    
    % Adjustable threshold values
    filt_low(1,n) = 0.1 * max(Config.bpass{1,n}(:)); % Lower intensity threshold set to 10% of max value
    filt_low(2,n) = 0.1 * max(Config.bpass{3,n}(:)); % Lower intensity threshold set to 10% of max value
    filt_sz = 3;    % Size variation of beads
    
    Config.peak{1,n} = pkfnd(Config.bpass{1,n},filt_low(1,n),filt_sz);
    Config.peak{2,n} = pkfnd(Config.bpass{3,n},filt_low(2,n),filt_sz);

    Config.peakCenter{1,n} = cntrd(Config.bpass{1,n}, Config.peak{1,n}, 15);
    Config.peakCenter{2,n} = cntrd(Config.bpass{3,n}, Config.peak{2,n}, 15);


    % Find corresponding beads
    Config.mask = 3; % Find beads within range of pixels
    Config.list{n} = zeros(size(Config.peakCenter{1,n},1),1);

    for k = 1 : size(Config.peakCenter{1,n},1)
       x = linspace(Config.peakCenter{1,n}(k,1) - Config.mask, Config.peakCenter{1,n}(k,1)+ Config.mask, 2*Config.mask+1);
       y = linspace(Config.peakCenter{1,n}(k,2) - Config.mask, Config.peakCenter{1,n}(k,2) + Config.mask, 2*Config.mask+1);
       for i = 1 : size(Config.peakCenter{2,n},1)
           if ~isempty(find(x > Config.peakCenter{2,n}(i,1) - Config.mask)) && ~isempty(find(x < Config.peakCenter{2,n}(i,1) + Config.mask)) && ...
              ~isempty(find(y > Config.peakCenter{2,n}(i,2) - Config.mask)) && ~isempty(find(y < Config.peakCenter{2,n}(i,2) + Config.mask))

              Config.list{n}(k,1) = i;
          end
       end
    end

    for i = 1 : size(Config.list{n},1)
        if Config.list{n}(i,1) ~= 0
            Config.Pos{1,n}(i,1) = Config.peakCenter{1,n}(i,1);
            Config.Pos{1,n}(i,2) = Config.peakCenter{1,n}(i,2);
            Config.Pos{2,n}(i,1) = Config.peakCenter{2,n}(Config.list{n}(i),1);
            Config.Pos{2,n}(i,2) = Config.peakCenter{2,n}(Config.list{n}(i),2);
        end
    end

    for k = 1: size(Config.Pos{1,n},1)
           if k <= size(Config.Pos{1,n},1) && Config.Pos{1,n}(k,1) == 0
           Config.Pos{1,n}(k,:)=[];
           Config.Pos{2,n}(k,:)=[];
           k = k-1;
           end
    end
    
end

% Collect all bead positions
Config.Trans = cell(1,2);
for n=1:num
Config.Trans{1} = [Config.Trans{1}; Config.Pos{1,n}];
Config.Trans{2} = [Config.Trans{2}; Config.Pos{2,n}];
end


% Remove rows containing zero
Config.Trans{1}( ~any(Config.Trans{1},2), :) = [];
Config.Trans{2}( ~any(Config.Trans{2},2), :) = [];

Num_beads = 500;
if size(Config.Trans{1},1) > Num_beads
    Config.Trans{1} = Config.Trans{1}(1:Num_beads,:);
    Config.Trans{2} = Config.Trans{2}(1:Num_beads,:);
end



% Retrieve the translation parameters
tform = fitgeotrans(Config.Trans{2},Config.Trans{1},'lwm',64);

% Translate distorted stacks
if size(Stack,2) == 2 && numel(idx) == 1
    Selection = find(~cellfun('isempty',strfind(Config.WaveLengths,Config.Index{idx,Config.Index{idx,5}})));
elseif size(Stack,2) == 2 && numel(idx) == 2
    Selection = find(cellfun(@(x) x>0,Config.Index(idx,5)));
elseif size(Stack,2) == 1
    Selection = 1;    
end

% TO BE REMOVED
% if size(Stack,2) == 2 && sum(~cellfun('isempty',Config.Index(idx,2:3))) == 1
%     Selection = find(cellfun(@(x) x>0,Config.Index(idx,5)));
% elseif size(Stack,2) == 2 && sum(~cellfun('isempty',Config.Index(idx,2:3))) == 2
%     Selection = find(~cellfun('isempty',strfind(Config.WaveLengths,Config.Index{idx,Config.Index{idx,5}})));
% elseif size(Stack,2) == 1
%     Selection = 1;
% end

for n = 1 : length(Selection)
    if length(Stack) == 2
        Im1 = Stack{1,Selection(n)};
    else
        Im1 = Stack{1};
    end
    N = size(Im1,2);
    var1 = Result(3);
    var2 = Result(4);
    tempOutput = cell(1,N);
    if Config.CPU == 1
        
        % Divide up parfor-loops for progressbar to function
        for_split = 0:10:N;
        for_split(end+1) = (N-for_split(end)) + for_split(end);
        
        for i = 1 : length(for_split)-1
            parfor k = for_split(i)+1 : for_split(i+1)
               tempStack =  imtranslate(Im1{1,k}, [var1 var2]);
               R = imref2d([512 512]);
               tempOutput{1,k}(:,:) = imwarp(tempStack,tform,'Interp', 'bilinear', 'OutputView', R);
            end
        Config.Status{Config.Status_Count} = i/(length(for_split)-1);
        progressbar(Config.Status{:});
        end
    elseif Config.CPU == 0
        for k = 1 : N
           tempStack =  imtranslate(Im1{1,k}, [var1 var2]);
           R = imref2d([512 512]);
           tempOutput{1,k}(:,:) = imwarp(tempStack,tform,'Interp', 'bilinear', 'OutputView', R);
           Config.Status{Config.Status_Count} = k/N;
           progressbar(Config.Status{:});
        end
    end
    Stack{2,Selection(n)} = tempOutput;
end


for n = 1 : size(Stack,2)
    if ~isempty(Stack{1,n}) && isempty(Stack{2,n})
       Stack{2,n} = Stack{1,n}; 
    end
end

Config.Status_Count = Config.Status_Count + 1;

end

function Drift(idx,~)
global Stack Config         

if size(Stack,2) >1  && numel(idx) == 1
    s = 1;
    Selection = find(cellfun(@(x) x>0,Config.Index(idx,6)));
    Other = find(linspace(1,length(Stack),length(Stack)) ~= Selection);

    % Name SaveFiles
    for n = 1 : size(Stack,2)
        Config.SaveName{1} = strrep(Config.FileName{1,idx},'.nd',strcat('_',Config.WaveLengths{1},'.tif'));
    end
    
elseif size(Stack,2) == 2 && numel(idx) == 2
    s = 1;
    Selection = find(cellfun(@(x) x>0,Config.Index(idx,6)));
    Other = find(cellfun(@(x) x==0,Config.Index(idx,6)));
elseif size(Stack,2) == 1
    s = 0;
    Selection = 1;
end
    
order = size(Stack,1);

tempOutput_S = [];
tempOutput_O = [];

% Calculate drift correction with reference stack
nFrames = size(Stack{1,Selection},2);

for k = 1 : nFrames
   Im1 = Stack{order,Selection}{1,1};
   Im2 = Stack{order,Selection}{1,k};
   Result = dftregistration(fft2(Im1), fft2(Im2), 100);
   Output(k,1) = Result(3);
   Output(k,2) = Result(4);

   Config.Status{Config.Status_Count} = k/(2*nFrames);
   progressbar(Config.Status{:});
end

    
% Translate the stacks
Stack{3,Selection}{1,1} = Stack{order,Selection}{1,1};
Im_S = Stack{order,Selection};

if s == 1
    for j = 1 : length(Other)
        Stack{3,Other(j)}{1,1} = Stack{order,Other(j)}{1,1};
        Im_O{j} = Stack{order,Other(j)};
    end
end


var1 = Output(:,1);
var2 = Output(:,2);
tempOutput_S = cell(1,nFrames);
if s ==1
    tempOutput_O = cell(1,length(Other));
end

    if Config.CPU == 1
        
        for_split = 0:10:nFrames;
        if nFrames-for_split(end) > 0
            for_split(end+1) = (nFrames-for_split(end)) + for_split(end);
        end
        
        for i = 1 : length(for_split)-1
            for k = for_split(i)+1 : for_split(i+1)
                Image1 = Im_S{1,k};
                tempStack1 = imtranslate(Image1, [var1(k) var2(k)]);
                tempOutput_S{1,k} = tempStack1;
                if s == 1
                    for j = 1 : length(Other)
                        Image2 = Im_O{j}{1,k};
                        tempStack2 = imtranslate(Image2, [var1(k) var2(k)]);
                        tempOutput_O{j}{1,k} = tempStack2;
                    end
                end

            end
            Config.Status{Config.Status_Count} = i/(length(for_split)-1);
            progressbar(Config.Status{:});
        end

    elseif Config.CPU == 0
        for k = 1 : nFrames
            tempStack1 = imtranslate(Im_S{1,k}, [var1(k) var2(k)]);
            tempOutput_S{1,k} = tempStack1;
            if s == 1
                for j = 1 : length(Other)
                    tempStack2 = imtranslate(Im_O{j}{1,k}, [var1(k) var2(k)]);
                    tempOutput_O{j}{1,k} = tempStack2;
                end
            end
            Config.Status{Config.Status_Count} = (nFrames+k)/(2*nFrames);
            progressbar(Config.Status{:});
        end 
    end
    
    for k = 2 : nFrames
        Stack{3,Selection}{1,k} =  tempOutput_S{1,k};
        if s == 1
            for j = 1 : length(Other)
                Stack{3,Other(j)}{1,k} = tempOutput_O{j}{1,k};
            end
        end
    end
    
Config.Status_Count = Config.Status_Count + 1;    
end

function Wiener(method,~)
global Stack Config

order = size(Stack,1);
PSF = fspecial('gaussian');

% Method 1
if method == 1
for n = 1 : size(Stack,2)
    for i = 1 : size(Stack{order,n},2)
       Stack{4,n}{1,i} = deconvwnr(Stack{order,n}{1,i},PSF);
       Config.Status{Config.Status_Count} = (((n-1)*size(Stack{order,n},2))+i)/...
                                            (size(Stack,2) * size(Stack{order,n},2));
       progressbar(Config.Status{:});
    end
end

elseif method == 2
% Method 2
for n = 1 : size(Stack,2)
    for i = 1 : size(Stack{order,n},2)
        [~,noise] = wiener2(Stack{order,n}{1,i},[3 3]);
        Stack{4,n}{1,i} = wiener2(Stack{order,n}{1,i},[3 3],noise);
       Config.Status{Config.Status_Count} = (((n-1)*size(Stack{order,n},2))+i)/...
                                            (size(Stack,2) * size(Stack{order,n},2));
       progressbar(Config.Status{:});
    end
end
end

Config.Status_Count = Config.Status_Count + 1;

end

function Wallis(Parameter,~)
global Stack Config

if ~isempty(Parameter)
    m_target = Parameter(1);
    s_target = Parameter(2);
    c = Parameter(3);
    b = Parameter(4);
else
    m_target = 127; % target mean 
    s_target = 60; % target std
    c = 0.9; % contrast expansion coefficient
    b = 0.9; % brightness forcing constant 0= original image; 1= target image
end

order = size(Stack,1);
windowSize = 45;
kernel = ones(windowSize)/windowSize^2;
nHood = ones(windowSize);

for n = 1 : size(Stack,2)
    for i = 1 : size(Stack{order,n},2)
       grayImage = im2uint8(Stack{order,n}{1,i});
       meanImage = conv2(double(grayImage),kernel,'same');
       sdImage = stdfilt(double(grayImage),nHood);
       
       % Compute the output image
       % I_wallis = I_org *r1 + r0
       % r1 = (c * s_org)/(c* s_org + s_target/c)
       % r0 = b * m_target + (1 - b - r1)*m_org
       
       r1 = (c .* sdImage) ./ (c .* sdImage + (s_target/c));
       r0 = b * m_target + (1 - b - r1).*meanImage;
       
       Im_wallis = double(grayImage).*r1 + r0;
       Stack{5,n}{1,i} = im2uint16(Im_wallis);
       Config.Status{Config.Status_Count} = (((n-1)*size(Stack{order,n},2))+i)/...
                                            (size(Stack,2) * size(Stack{order,n},2));
       progressbar(Config.Status{:});

    end  
 
end
Config.Status_Count = Config.Status_Count + 1;
end

function Background(~,~)
global Stack Config

    % Initialize parameters
    window = str2double(Config.BkgSize);       
    order = size(Stack,1);    
     
    for n = 1 : size(Stack,2)  
       N = size(Stack{order,n},2);
       Im1 = Stack{order,n};
       var1 = char(Config.BkgShape{1});
       Background = zeros(size(Stack{order,n}{1},1), size(Stack{order,n}{1},2), N);
       Output = cell(1,N);
       
       if Config.CPU == 1
           
           for_split = 0:10:N;
           for_split(end+1) = (N-for_split(end)) + for_split(end);
        
        for i = 1 : length(for_split)-1
            parfor k = for_split(i)+1 : for_split(i+1)
              Background(:,:,k) = imopen(Im1{1,k},strel(var1, window));
            end
           Config.Status{Config.Status_Count} = i/(length(for_split)-1);
           progressbar(Config.Status{:});
        end
       elseif Config.CPU == 0
           for k = 1 : N
              Background(:,:,k) = imopen(Im1{1,k},strel(var1, window));
              Config.Status{Config.Status_Count} = k/N; 
              progressbar(Config.Status{:});
           end
       end
       var2 = uint16(mean(Background,3));
       for l = 1 : N
          tempOutput = Im1{1,l} - var2;
          Output{1,l} = tempOutput;
       end
    Stack{6,n} = Output;
    end 
   
Config.Status_Count = Config.Status_Count + 1;
    
end

function Bleach(~,~)
global Stack Config

for n = 1 : size(Stack,2)
   
    
end

end

function Export(number,string)
global Stack Config

SaveFolder = strcat(Config.PathName,'Output\');

if exist(SaveFolder)~=7
    mkdir(SaveFolder);
end
    
% Record the applied corrections
% Config.number = strcat(num2str(number-1),'_',Config.number); 
Config.number = string;

    for n = 1 : size(Stack,2)
                         
%         file = strcat(SaveFolder, num2str(number-1),'_',Config.SaveName{1,n});
        file = strcat(SaveFolder, Config.number, Config.SaveName{1,n});
        
        Stack_arr = [];
        for m = 1 : length(Stack{number,n})
          Stack_arr(:,:,m) = Stack{number,n}{m};
        end
        
        writetiffstack(file, Stack_arr, 32);
        
%         for i = 1 : size(Stack{number,n},2)  
%            if i == 1
%                imwrite(Stack{number,n}{1,i},file,'tiff','Compression','none','WriteMode','overwrite');
%            else
%                imwrite(Stack{number,n}{1,i},file,'tiff','Compression','none','WriteMode','append');
%            end
           
%         Config.Status{end} = (((n-1)*size(Stack{number,n},2))+i)/...
%                                             (size(Stack,2) * size(Stack{number,n},2));

        Config.Status{end} = n/(size(Stack,2));
        progressbar(Config.Status{:});   
           
%         end
    end   
end