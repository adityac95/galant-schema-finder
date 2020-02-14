%% Aditya Chander || 15 May 2019 || Search algorithm
%
% This function runs the algorithm to search for schemata. It's
% been decomposed considerably to account for different csv files. This
% process involves:
% 1. paring everything down a bit more so that we only have the relevant
% info from the csv file
% 2. separating out each piece
% 3. for each piece, for each mode, for each rhythm, for each schema
% run the search algorithm with different tolerance values

function output_struct = search_algorithm_1(input_struct, csv_file, output_file, tolerance)

% read in the csv
csv_table = table2array(readtable(csv_file));
csv_table = csv_table(:,[1:4 8]);

% extract individual pieces from the csv and fill a struct
line_count = 2; % start on second line
piece_count = 1;
pieces = struct;
while line_count < length(csv_table)
    pieces(piece_count).data = csv_table(csv_table(:,5)==piece_count,1:4);
    line_count = line_count + length(pieces(piece_count).data);
    piece_count = piece_count + 1;
end

% define an output struct
output_struct = struct;
for i = 1:length(input_struct)
    for j = 1:length(pieces)
        output_struct(j).piece(i).type = input_struct(i).type;
        output_struct(j).piece(i).major = struct;
        output_struct(j).piece(i).minor_h = struct;
        output_struct(j).piece(i).minor_m = struct;
        output_struct(j).piece(i).minor_n = struct;
    end
end

% populate the output struct with results from the search algorithm
results = fopen(output_file, 'w');
fprintf(results,[mat2str(tolerance) '\n\n']);
for k = 1:length(pieces)
    for i = 1:length(input_struct)
        %        for j = 1:size(input_struct(i).time,1)
        for l = 1:length(input_struct(i).time_scalers)
            ts = input_struct(i).time_scalers(l); % add this to input struct
            rhythm = input_struct(i).rhythm.*ts;
            time = input_struct(i).time.*ts;
            for m = 1:length(tolerance)
                output_struct(k).piece(i).major(m).tolerance = tolerance(m);
                output_struct(k).piece(i).minor_h(m).tolerance = tolerance(m);
                output_struct(k).piece(i).minor_m(m).tolerance = tolerance(m);
                output_struct(k).piece(i).minor_n(m).tolerance = tolerance(m);
                output_struct(k).piece(i).major(m).timescaler(l).ts = ts;
                output_struct(k).piece(i).minor_h(m).timescaler(l).ts = ts;
                output_struct(k).piece(i).minor_m(m).timescaler(l).ts = ts;
                output_struct(k).piece(i).minor_n(m).timescaler(l).ts = ts;
                %                     if ~exist('output_struct(k).piece(i).major(m).timescaler(l).found')
                %                         %fprintf('maj %d %d %d %d %d \n',k,i,j,l,m)
                %                         output_struct(k).piece(i).major(m).timescaler(l).found = [];
                %                     end
                %                     if ~exist('output_struct(k).piece(i).minor_h(m).timescaler(l).found')
                %                         %fprintf('minh %d %d %d %d %d \n',k,i,j,l,m)
                %                         output_struct(k).piece(i).minor_h(m).timescaler(l).found = [];
                %                     end
                %                     if ~exist('output_struct(k).piece(i).minor_m(m).timescaler(l).found')
                %                         %fprintf('minm %d %d %d %d %d \n',k,i,j,l,m)
                %                         output_struct(k).piece(i).minor_m(m).timescaler(l).found = [];
                %                     end
                %                     if ~exist('output_struct(k).piece(i).minor_n(m).timescaler(l).found')
                %                         %fprintf('minn %d %d %d %d %d \n',k,i,j,l,m)
                %                         output_struct(k).piece(i).minor_n(m).timescaler(l).found = [];
                %                     end
                output_struct(k).piece(i).major(m).timescaler(l).found = search_alg_wrapper(input_struct(i).major, time, rhythm, tolerance(m), pieces(k).data);
                output_struct(k).piece(i).minor_h(m).timescaler(l).found = search_alg_wrapper(input_struct(i).minor_h, time, rhythm, tolerance(m), pieces(k).data);
                output_struct(k).piece(i).minor_m(m).timescaler(l).found = search_alg_wrapper(input_struct(i).minor_m, time, rhythm, tolerance(m), pieces(k).data);
                output_struct(k).piece(i).minor_n(m).timescaler(l).found = search_alg_wrapper(input_struct(i).minor_n, time, rhythm, tolerance(m), pieces(k).data);
                tmp_out = [output_struct(k).piece(i).major(m).timescaler(l).found;
                    output_struct(k).piece(i).minor_h(m).timescaler(l).found;
                    output_struct(k).piece(i).minor_m(m).timescaler(l).found;
                    output_struct(k).piece(i).minor_n(m).timescaler(l).found];
                if ~(size(tmp_out,1) == 0 || size(tmp_out,2)==0)
                    fprintf(results,'schema %s, piece %d, timescaler %0.2f, tolerance %0.2f \n',output_struct(k).piece(i).type,...
                        k,...
                        output_struct(k).piece(i).minor_h(m).timescaler(l).ts,tolerance(m));
                    fprintf(results,['maj size: ' mat2str(size(output_struct(k).piece(i).major(m).timescaler(l).found,1)) ' ' ...
                        'min_h size: ' mat2str(size(output_struct(k).piece(i).minor_h(m).timescaler(l).found,1)) ' ' ...
                        'min_m size: ' mat2str(size(output_struct(k).piece(i).minor_m(m).timescaler(l).found,1)) ' ' ...
                        'min_n size: ' mat2str(size(output_struct(k).piece(i).minor_n(m).timescaler(l).found,1)) '\n\n']);
                    fprintf('schema %s, piece %d, timescaler %0.2f, tolerance %0.2f \n',output_struct(k).piece(i).type,...
                        k,...
                        output_struct(k).piece(i).minor_h(m).timescaler(l).ts,tolerance(m))
                    fprintf(['maj size: ' mat2str(size(output_struct(k).piece(i).major(m).timescaler(l).found,1)) ' ' ...
                        'min_h size: ' mat2str(size(output_struct(k).piece(i).minor_h(m).timescaler(l).found,1)) ' ' ...
                        'min_m size: ' mat2str(size(output_struct(k).piece(i).minor_m(m).timescaler(l).found,1)) ' ' ...
                        'min_n size: ' mat2str(size(output_struct(k).piece(i).minor_n(m).timescaler(l).found,1)) '\n\n'])
                end
            end
        end
        %         end
    end
end
closed = fclose(results);

end

% wrapper that subsets the struct and calls the algorithm
function output_matrix = search_alg_wrapper(input_struct, times, rhythms, tol, piece)

% initialise the output matrix; this will contain pairs of beat numbers
% that mark the beginning and ending of the occurrence(s) inclusive
output_matrix = [];

% extract the melody for ease
melody = input_struct.melody;

% subset the piece into melody and bass lines; only beat and pitch info
% needed; rhythm for now but we will add an extra end of piece token
piece_mel_tmp = piece(piece(:,3)==0, [1 2 4]);
piece_bass_tmp = piece(piece(:,3)==1, [1 2 4]);

if (size(piece_mel_tmp,1) == 0 || size(piece_mel_tmp,2) == 0)
    return;
end;
if (size(piece_bass_tmp,1) == 0 || size(piece_bass_tmp,2) == 0)
    return;
end;

% add an end-of-piece token, which is essentially an extra note of pitch 0
piece_mel = [piece_mel_tmp(:,[1 3]); piece_mel_tmp(end,1)+piece_mel_tmp(end,2) 0];
piece_bass = [piece_bass_tmp(:,[1 3]); piece_bass_tmp(end,1)+piece_bass_tmp(end,2) 0];

% loop over the whole piece and start searching each window.
% window is calculated according to duration of the schema and the
% tolerance. in each case, the first note to check will be whatever is the
% loop index (beginning from 0). the last note to check will be the loop
% index plus the duration specified by the last value in the time vector,
% plus whatever tolerance is allowed. some tolerances might be smaller
% because of the duration limits of the piece. in this case the tolerance
% windows just get truncated.

% % last notes that can begin a window
% limit_mel = piece_mel(end,1)-time(end);
% limit_bass = piece_bass(end,1)-time(end); % -(tol*rhythm(end)*0.5);
%
% % find indices closest to these limits
% tmp_mel_inds = find(piece_mel(:,1) <= limit_mel);
% tmp_bass_inds = find(piece_bass(:,1) <= limit_bass);
% last_mel_ind = tmp_mel_inds(end)+1;
% last_bass_ind = tmp_bass_inds(end)+1;

% just set the limit to the last note for now
last_mel_ind = length(piece_mel);

% rhythm loop
for irhythm = 1:size(times,1)
    time = times(irhythm,:);
    rhythm = rhythms(irhythm,:);
    % melody loop
    for inote = 1:last_mel_ind
        % % make sure we stop if the melody is longer than the bass
        % if inote > last_bass_ind
        %    break;
        % end
        % % we don't actually want this because it's about the beat. so leave
        % it out for now
        
        % find the last position to check and define window
        wind_inds_mel = find(piece_mel(:,1) <= piece_mel(inote)+time(end)+(tol*rhythm(end)*0.5));
        wind_limit_mel = wind_inds_mel(end);
        wind_mel = piece_mel(inote:wind_limit_mel,:);
        
        % try finding the melody
        [mel_found,mel_first,mel_last] = is_found(melody, wind_mel, time, rhythm, tol, true, piece_mel(inote,:));
        if mel_found
            % define the bass window
            wind_inds_bass = find(piece_bass(:,1) < piece_mel(inote)+time(end)+(tol*rhythm(end)*0.5));
            if size(wind_inds_bass,1) == 0 || size(wind_inds_bass,2) == 0
                continue;
            end
            %disp(mat2str(wind_inds_bass));
            wind_limit_bass = wind_inds_bass(end);
            % tmp_beginning in beats from beginning
            tmp_beginning = piece_mel(inote,1)-tol*rhythm(1)*0.5;
            if tmp_beginning < 0
                tmp_beginning = 0;
            end
            [close_val,close_idx] = min(abs(tmp_beginning-piece_bass(:,1)));
            wind_bass = piece_bass(close_idx:wind_limit_bass,:);
            for ibassline = 1:size(input_struct.bass,1)
                bass = input_struct.bass(ibassline,:);
                [bass_found,bass_first,bass_last] = is_found(bass, wind_bass, time, rhythm, tol, false, piece_mel(inote,:));
                if bass_found
                    bass_whole_first = find(piece(:,1)==bass_first & piece(:,3)==1);
                    mel_whole_first = find(piece(:,1)==mel_first & piece(:,3)==0);
                    bass_whole_last = find(piece(:,1)==bass_last & piece(:,3)==1);
                    mel_whole_last = find(piece(:,1)==mel_last & piece(:,3)==0);
                    if length(bass_whole_last) == 0
                        continue;
                    elseif length(mel_whole_last) == 0
                        continue;
                    end
                    overall_first = bass_whole_first(1);
                    if bass_whole_first(1) > mel_whole_first(1); overall_first(1) = mel_whole_first(1); end
                    overall_last = bass_whole_last(end);
                    if bass_whole_last(end) < mel_whole_last(end); overall_last(end) = mel_whole_last(end); end
                    %disp(output_matrix);disp(overall_first);disp(overall_last);
                    output_matrix = [output_matrix; overall_first(1) overall_last(end) irhythm];
                    if size(output_matrix,2)~=3
                        disp(size(output_matrix)); % should be (something, 3)
                    end
                end
            end
        end
    end
end

end


% performs the search
function [found,first,last] = is_found(notes, wind, time, rhythm, tol, is_melody, start_mel)

% boolean flag for search
found = true;

start = 1;
if is_melody
    start = 2;
    first = start_mel(1);
end

% loop over the time vector
for i = start:length(time)
    if notes(i) > floor(notes(i))
        continue;
    end
    offset = rhythm(i)*tol*0.5;
    time_range = [time(i)-offset time(i)+offset];
    % use start_mel in case of bass line
    search_window = wind(wind(:,1) >= time_range(1)+start_mel(1) & wind(:,1) <= time_range(2)+start_mel(1),:);
    if (size(search_window,1) == 0 || size(search_window,2) == 0)
        found = false;
        first = -1;
        last = -1;
        return;
    end
    to_find = mod(notes(i),12);
    result = search_window(mod(search_window(:,2)-start_mel(2),12) == to_find);
    if (size(result,1) == 0 || size(result,2) == 0)
        found = false;
        first = -1;
        last = -1;
        return;
    end
    if i == 1
        first = result(1);
    end
end

last = result(1);

end
