%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Post processing of SAD output. Connects close segements and deletes 
% outliers 
%
% input:    SAD output (Matrix with SAD decisions)
% output:   Smoothed SAD output
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

function turns = get_turns(input)
    
    % parameter
    frame_len_1 = 20; % distance for decision of connection (frames)
    frame_len_2 = 30; % distance for decision of outliers (frames)
    frame_shift = 1;    
    num_frames_3 = 2; % # number of frames for extension
    
    % start processing
    n_len = length(input(:,1));
    num_frames_1 = floor((n_len-frame_len_1)/frame_shift)+1;  % # of frames
    num_frames_2 = floor((n_len-frame_len_2)/frame_shift)+1;  % # of frames
    
    turns = input;    
   
    % Connect close segments
    s_idx = 1;
    for i = 1:num_frames_2
        % frame end index
        e_idx = s_idx + frame_len_2 - 1;        
        y = input(s_idx:e_idx,:);
        
        for j = 1:length(input(1,:))
            f = find(y(:,j));
            if ~isempty(f) && length(f) > 1 
                if (f(end)-f(1) + 1) > length(f)
                    turns(s_idx+f(1)-1:s_idx+f(end)-1,j) = 1;
                end                
            end
        end        
        % next frame start index
        s_idx = s_idx + frame_shift;
    end
    
    % Delete outliers
    s_idx = 1;
    for i = 1:num_frames_1
        % frame end index
        e_idx = s_idx + frame_len_1 - 1;        
        y = turns(s_idx:e_idx,:);
        
        for j = 1:length(input(1,:))
            f = find(~y(:,j));
            if ~isempty(f) && length(f) > 1 
                if (f(end)-f(1) + 1) > length(f)
                    turns(s_idx+f(1)-1:s_idx+f(end)-1,j) = 0;
                end                
            end
        end        
        % next frame start index
        s_idx = s_idx + frame_shift;
    end
    
    % Extend segments
    y = turns;
    for j = 1:length(input(1,:))
       for ii=num_frames_3:length(input(:,1))
           if y(ii,j) == 1
               turns(ii-num_frames_3:ii+num_frames_3,j) = 1;
           end
       end
    end
end

