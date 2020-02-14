%% Aditya Chander || 30 Apr 2019 || Schema degree parser
%
% Converts a text file (.txt or .csv) formatted as
% SchemaName,TimeSeriesType,TimeSeries line by line to a struct. Entries
% under the headers SchemaName and TimeSeriesType are strings; TimeSeries
% entries are formatted as arrays e.g. [2 4 1 4 5].
%
% This function does not convert the degrees in each time series to an
% intervallic format. This is handled in a separate function.

function output_struct = schema_degree_parser(filename)

% initialise data variables
file_content = table2cell(readtable(filename));
output_struct = struct;

% strip whitespace
for i = 1:size(file_content,1)
    for j = 1:size(file_content,2)
        file_content(i,j) = strtrim(file_content(i,j));
    end
end

% populate struct
type_counter = 0;
interval_counter = 0;
tmp_type = '';

for i = 1:size(file_content,1)
    % initialise entry for the next type
    if tmp_type ~= string(file_content{i,1})
        type_counter = type_counter + 1;
        output_struct(type_counter).type = string(file_content{i,1});
        output_struct(type_counter).melody = [];
        output_struct(type_counter).bass = [];
        output_struct(type_counter).time = [];
        output_struct(type_counter).time_scalers = [];
        tmp_type = string(file_content{i,1});
    end
    intervals = file_content{i,3};
    intervals = intervals(2:end-1);
    interval_split = split(intervals,' ');
    interval_list = [];
    for j = 1:size(interval_split,1)
        elt = char(interval_split{j,1});
        interval_list = horzcat(interval_list, str2num(elt));
    end
    label = string(file_content{i,2});
    if label == 'm'
        output_struct(type_counter).melody = vertcat(output_struct(type_counter).melody, interval_list);
    elseif label == 'b'
        output_struct(type_counter).bass = vertcat(output_struct(type_counter).bass, interval_list);
    elseif label == 't'
        output_struct(type_counter).time = vertcat(output_struct(type_counter).time, interval_list);
    elseif label == 's'
        output_struct(type_counter).time_scalers = vertcat(output_struct(type_counter).time_scalers, interval_list);
    end
end