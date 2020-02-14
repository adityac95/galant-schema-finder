%% Aditya Chander || 30 Apr 2019 || Timeseries struct converter
%
% Converts a struct with fields "type", "melody", "bass" and "time" to an
% intervallic format. The melody and bass intervals will be calculated
% relative to the starting note for both major and minor modes. Time
% intervals will be calculated in a similar fashion, though no adjustment
% is necessary for major and minor modes.

function output_struct = timeseries_struct_converter(input_struct)

% initialise output
output_struct = struct;

% populate the output struct
for i = 1:size(input_struct,2)
    
    % retrieve the appropriate row
    field = input_struct(i);
    
    % make new entry in the output struct
    output_struct(i).type = field.type;
    
    % structs for major and 3 x minor modes
    major = struct('melody',[],'bass',[]);
    minor_h = struct('melody',[],'bass',[]);
    minor_m = struct('melody',[],'bass',[]);
    minor_n = struct('melody',[],'bass',[]);
    
    % populate them
    for j = 1:size(field.melody,1)
        [m1 m2 m3 m4] = convert_from_raw(field.melody(j,:), field.melody(j,1));
        major.melody = [major.melody; m1];
        minor_h.melody = [minor_h.melody; m2];
        minor_m.melody = [minor_m.melody; m3];
        minor_n.melody = [minor_n.melody; m4];
    end
    for k = 1:size(field.bass,1)
        [n1 n2 n3 n4] = convert_from_raw(field.bass(k,:), field.melody(j,1));
        major.bass = [major.bass; n1];
        minor_h.bass = [minor_h.bass; n2];
        minor_m.bass = [minor_m.bass; n3];
        minor_n.bass = [minor_n.bass; n4];
    end
    
    % construct the new time array
    new_time = [];
    for l = 1:size(field.time,1)
        tmp_time = field.time(l,:);
        tmp_new_time = [0];
        for m = 1:size(tmp_time,2)
            tmp_new_time = [tmp_new_time tmp_time(m)+tmp_new_time(m)];
        end
        new_time = [new_time; tmp_new_time(1:end-1)];
    end
    
    % put it all together
    output_struct(i).major = major;
    output_struct(i).minor_h = minor_h;
    output_struct(i).minor_m = minor_m;
    output_struct(i).minor_n = minor_n;
    output_struct(i).time = new_time;
    output_struct(i).rhythm = input_struct(i).time;
    output_struct(i).time_scalers = input_struct(i).time_scalers;
    
end

end

% This helper function spits out the intervallic structure for the four
% different mode types given the original format.
function [maj min_h min_m min_n] = convert_from_raw(raw_pitch_intervals, first_degree)

% mappings for major and minor scales
major = [0 2 4 5 7 9 11];
minor_harmonic = [0 2 3 5 7 8 11];
minor_melodic = [0 2 3 5 7 9 11];
minor_natural = [0 2 3 5 7 8 10];

% empty arrays
raw_maj = [];
raw_min_h = [];
raw_min_m = [];
raw_min_n = [];

for i = 1:size(raw_pitch_intervals,2)
    if raw_pitch_intervals(i) ~= -1
        raw_maj = [raw_maj major(raw_pitch_intervals(i))];
        raw_min_h = [raw_min_h minor_harmonic(raw_pitch_intervals(i))];
        raw_min_m = [raw_min_m minor_melodic(raw_pitch_intervals(i))];
        raw_min_n = [raw_min_n minor_natural(raw_pitch_intervals(i))];
    else % had to convert -1 to 0.1 because we may want -1 as an interval
        raw_maj = [raw_maj 0.1];
        raw_min_h = [raw_min_h 0.1];
        raw_min_m = [raw_min_m 0.1];
        raw_min_n = [raw_min_n 0.1];
    end
end

% zero-centre about first melody scale degree
first_maj = major(first_degree);
first_min_h = minor_harmonic(first_degree);
first_min_m = minor_melodic(first_degree);
first_min_n = minor_natural(first_degree);

offset_maj = first_maj-raw_maj(1);
offset_min_h = first_min_h-raw_min_h(1);
offset_min_m = first_min_m-raw_min_m(1);
offset_min_n = first_min_n-raw_min_n(1);

maj = raw_maj-raw_maj(1)-offset_maj;
min_h = raw_min_h-raw_min_h(1)-offset_min_h;
min_m = raw_min_m-raw_min_m(1)-offset_min_m;
min_n = raw_min_n-raw_min_n(1)-offset_min_n;

end
