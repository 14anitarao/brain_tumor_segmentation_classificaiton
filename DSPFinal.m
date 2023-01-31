% MATLAB 3
% reads file
% filename = 'mvi_2617_cut.mp4'; 
% MOV = VideoReader(filename); 
% vid = read(MOV);
% num_frames = MOV.NumberOfFrames;
% PART A:
% function which extracts dimensions of an image and number of frames
% Height:1080, Width:1920, Number of Frames:689
% 
% declares a folder for the data to be stored 
% DATA = 'DSPPlotsNew';
% mkdir(DATA) 
% mkdir(DATA,'difference_frames')



%%PART B:
%loop for calculating the difference frames
% initialFrame = read(MOV,1);
% for n=1:num_frames-1
%   Frame = read(MOV,n+1);
%   diffFrames{n} = im2bw(initialFrame - Frame,.1);
%   imwrite(diffFrames{n},fullfile(DATA,'difference_frames',['difference_frame-',sprintf('%03d',n),'.jpg']));
% end

%creation of a variable in order to index through the folder 
%'difference frames'
% imageNames = dir(fullfile(DATA,'difference_frames','*.jpg'));
% imageNames = {imageNames.name}';

% 
% bank = {};
% for i = 1:num_frames-1
%     stats = regionprops('table',diffFrames{i},'Centroid');
%     bank{i} = table2array(stats);
% end

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
        if (bank{i}(j,2) > 600) 
            upper{i} = [upper{i};bank{i}(j,:)];
        elseif (bank{i}(j,2) <= 600 && bank{i}(j,2) >= 400)
            middle{i} = [middle{i};bank{i}(j,:)];
        else
            lower{i} = [lower{i};bank{i}(j,:)];
        end
    end
    upper{i} = upper{i}(2:end,:);
    middle{i} = middle{i}(2:end,:);
    lower{i} = lower{i}(2:end,:);
end


%%% Calculate average particle velocity for each region %%%
cutoff = 750;

upper_velocity = avg_vel(upper,cutoff);
middle_velocity = avg_vel(middle,cutoff);
lower_velocity = avg_vel(lower,cutoff);

disp("Average velocity of UPPER particles:");
disp(upper_velocity);

disp("Average velocity of MIDDLE particles:");
disp(middle_velocity);

disp("Average velocity of LOWER particles:");
disp(lower_velocity);

function out = avg_vel(in,cutoff)
    after = {};
 
    for i = 1:(size(in,2) - 1)
        points = size(in{i+1},1);
        after{i} = [1,1];
        for j = 1:points
            if in{i+1}(j,1) >= cutoff
                after{i} = [after{i};in{i+1}(j,:)];
            end
        end
        after{i} = after{i}(2:end,:);
    end

    before = in;

    framerate = 477/19;
    
    time = 19/477;

    nearest_points = {};
    for i = 1:(size(in,2) - 1)
        nearest_points{i} = [1,1];
        while (size(after{i},1)>0)
            [~,I] = max(after{i}(:,2));
            dist = sqrt((after{i}(I,2) - before{i}(1,2))^2 + ...
                    (after{i}(I,1) - before{i}(1,1))^2);
            idx = 1;
            points = size(before{i},1);
            for j = 2:points
                new = sqrt((after{i}(I,2) - before{i}(j,2))^2 + ...
                    (after{i}(I,1) - before{i}(j,1))^2);
                if new < dist
                    dist = new;
                    idx = j;
                end
            end
            nearest_points{i} = [nearest_points{i};[before{i}(idx,1) ...
                after{i}(I,1)]];
            after{i}(I,:) = [];
            before{i}(j,:) = [];
        end
        nearest_points{i} = nearest_points{i}(2:end,:);
    end
    
    velocity = [];
    for i = 1:(size(in,2) - 1)
        % conversion from pixels to um
        velocity(i) = mean((nearest_points{i}(:,2) - ...
            nearest_points{i}(:,1))/time);
    end
   
    out = mean(velocity);
end