


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                                                       %%
%%                  DSP Final Project                    %%
%%     John Mavroudes, Anita Rao, & Zane Zemborain       %%
%%                 December 22th, 2017                   %%
%%                                                       %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                                                       %%
%%                  DSP Final Project                    %%
%%     John Mavroudes, Anita Rao, & Zane Zemborain       %%
%%                 December 22th, 2017                   %%
%%                                                       %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MATLAB 3
% reads file
% filename = 'mvi_2617_cut.mp4'; 
% MOV = VideoReader(filename); 
% vid = read(MOV);
% num_frames = MOV.NumberOfFrames;
% % PART A:
% % function which extracts dimensions of an image and number of frames
% % Height:1080, Width:1920, Number of Frames:689
% % 
% % declares a folder for the data to be stored 
% DATA = 'DSPPlotsNew';
% mkdir(DATA) 
% mkdir(DATA,'difference_frames')
% 
% 
% 
% %%PART B:
% %loop for calculating the difference frames
% initialFrame = read(MOV,1);
% for n=1:num_frames-1
%   Frame = read(MOV,n+1);
%   diffFrames{n} = im2bw(initialFrame - Frame,.1);
%   imwrite(diffFrames{n},fullfile(DATA,'difference_frames',['difference_frame-',sprintf('%03d',n),'.jpg']));
% end
% 
% %creation of a variable in order to index through the folder 
% %'difference frames'
% imageNames = dir(fullfile(DATA,'difference_frames','*.jpg'));
% imageNames = {imageNames.name}';

% 
bank = {};
for i = 1:num_frames-1
    stats = regionprops('table',diffFrames{i},'Centroid');
    bank{i} = table2array(stats);
end

%%% Generate images with superimposed bounding boxes %%%

% mkdir(DATA,'box_frames')
% path = fullfile(DATA,'box_frames');

% for i = 1:num_frames-1
%     img = imread(fullfile(DATA,'difference_frames',imageNames{i}));
%     imshow(img)
%     hold on
%     for j = 1:size(bank{i},1)
%         rectangle('Position', [bank{i}(j,1)-10, bank{i}(j,2)-10, 20, 20], ...
%             'EdgeColor', 'r', 'LineWidth', 3);
%     end
%     filename = ['box_frame-',sprintf('%03d',i),'.jpg'];
%     saveas(gcf, fullfile(path, filename));
% end

%%% Generate Output Video with Bounding Boxes %%%

% outputVideo = VideoWriter(fullfile(path,'outputCircles.avi'));
% outputVideo.FrameRate = MOV.FrameRate;
% open(outputVideo)
% 
% boxFrameNames = dir(fullfile(DATA,'box_frames','*.jpg'));
% boxFrameNames = {boxFrameNames.name}';
% 
% for ii = 1:length(boxFrameNames)
%    img = imread(fullfile(path,boxFrameNames{ii}));
%    writeVideo(outputVideo,img)
% end

%%% Create particle banks for upper, middle, and lower regions %%%

upper = {};
middle = {};
lower = {};

for i = 1:num_frames-1
    upper{i} = [1,1];
    middle{i} = [1,1];
    lower{i} = [1,1];
    points = size(bank{i},1);
    for j = 1:points
        if (bank{i}(j,2) > 550) 
            upper{i} = [upper{i};bank{i}(j,:)];
        elseif (bank{i}(j,2) <= 550 && bank{i}(j,2) >= 450)
            middle{i} = [middle{i};bank{i}(j,:)];
        else
            lower{i} = [lower{i};bank{i}(j,:)];
        end
    end
    upper{i} = upper{i}(2:end,:);
    middle{i} = middle{i}(2:end,:);
    lower{i} = lower{i}(2:end,:);
end

upper_velocity = avg_velocity(upper);
middle_velocity = avg_velocity(middle);
lower_velocity = avg_velocity(lower);

disp(upper_velocity)
disp(middle_velocity)
disp(lower_velocity)

function out = avg_velocity(Input)
    
    
    %Frame Rate of Camera
    Frame_Rate = 689/27;

    %Buffer Region
    Buffer_Cutoff = 0.05*1920;
    
    
    
    %Initialize After Array
    After = {};

    %Iterate through Centroids
    for i = 1:(size(Input,2) - 1)
        
        %Initialize Array
        After{i} = [1,1];
        
        %Points Circumscribing Centroid
        Points = size(Input{i+1},1);
        
        %Iterate through Points
        for j = 1:Points
            
            %Only Save Points After the Buffer Cutoff
            if Input{i+1}(j,1) >= Buffer_Cutoff
                After{i} = [After{i};Input{i+1}(j,:)];
            end
        end
        After{i} = After{i}(2:end,:);
    end
    
    %Before Processing
    Before = Input;

    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%   Find Nearest Neighbor   %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    
    
    %Create Empty Array for Nearest Neighbors
    Nearest_Points = {};
    
    
    for i = 1:(size(Input,2) - 1)
        
        %Intialize Array
        Nearest_Points{i} = [1,1];
        
        
        while (size(After{i},1)>0)
            
            
            [~,I] = max(After{i}(:,2));
            dist = sqrt((After{i}(I,2) - Before{i}(1,2))^2 + (After{i}(I,1) - Before{i}(1,1))^2);
            idx = 1;
            Points = size(Before{i},1);
            for j = 2:Points
                new = sqrt((After{i}(I,2) - Before{i}(j,2))^2 + ...
                    (After{i}(I,1) - Before{i}(j,1))^2);
                if new < dist
                    dist = new;
                    idx = j;
                end
            end
            Nearest_Points{i} = [Nearest_Points{i};[Before{i}(idx,1) ...
                After{i}(I,1)]];
            
            After{i}(I,:) = [];
   
        end 
        Nearest_Points{i} = Nearest_Points{i}(2:end,:);
    end
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%   Calculate Mean Velocity   %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    
    %Initialize Velocity Array
    Velocity = [];
    
    for i = 1:(size(Input,2) - 1)
        
        Time = 0.039;
        Temp_Velocity = (Nearest_Points{i}(:,2) - Nearest_Points{i}(:,1))/Time;
        
        
        %Calculate the Velocity of the Bead
        Velocity(i) = mean(Temp_Velocity);
    end
   
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%   Output Mean Velocity   %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    
%     Temp_Velocity = Velocity;
%     Temp_Size = size(Temp_Velocity,1);
%     Temp_Velocity = sort(Temp_Velocity);
%     Temp_Velocity = Temp_Velocity(round(Temp_Size/2):end,:);
%     Velocity = Temp_Velocity;


    %Ouput Mean Velocity for Region
    out = mean(Velocity);
end

