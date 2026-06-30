function avg_v = avg_speed_new

% Code created by Alexander Kiepas: alex.kiepas@gmail.com
% Last updated June 30, 2026

% For use with MTrackJ

%% Filepath code

persistent LastPath PathName

% If this is the first time running the function this session,
% initialize LastPath to 0
if isempty(LastPath) 
    LastPath = 0;
end

% First time calling 'uigetfile', use the pwd
if LastPath == 0
    [FileName, PathName] = uigetfile({'*.*','All Files(*.*)'}, ...
        'Select the RAW data file');
% All subsequent calls, use the path to the last selected file
else
    [FileName, PathName] = uigetfile(strcat(LastPath,'*.*'));
end

% If 'uigetfile' is called, but no item is selected, 'lastPath' is not
% overwritten with 0
if PathName ~= 0
    LastPath = PathName;
end
    
filepath = strcat(PathName,FileName);

%% Menu

answer = inputdlg({'Condition to be analyzed (sheetname)'}, ...
                   'Variables', 1);

% Variables based on menu input: 
    
    sheetname = answer{1,1};

%% Load  data into Matlab

num = readmatrix(filepath,'Sheet',sheetname);
% if metadata is accurate ...
    track = 2;
    xval = 4; % in microns
    yval = 5; % in microns
    time = 6; % in seconds

%% Calculate average speed

avg_v = NaN(max(num(:,track)),1); % blank matrix
f = unique(num(:,track));

for i = 1:length(f)
    current_track = f(i);
    idx = find(num(:,track) == current_track);
    dx = diff(num(idx,xval));
    dy = diff(num(idx,yval));
    dt = diff(num(idx,time))/60/60; % in hours
    dist = sqrt(dx.^2 + dy.^2);
    speed = dist./dt;
    avg_v(current_track,1) = mean(speed);
end

end