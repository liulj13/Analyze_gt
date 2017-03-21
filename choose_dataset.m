function dataset_path = choose_dataset(base_path)
%CHOOSE_DATASET
%   Allows the user to choose a dataset (sub-folder in the given path).
%   Returns the full path to the selected sub-folder.
%
%   Lijie Liu, 2017/3/21 modified from choose_video.m by Henriques

	%process path to make sure it's uniform
	if ispc(), base_path = strrep(base_path, '\', '/'); end  %ispc()==1 means Code to run on Windows platform
    %repalce the \ with / string replace
	if base_path(end) ~= '/', base_path(end+1) = '/'; end    %add a /
	
	%list all sub-folders
	contents = dir(base_path); %struct contains every item's name data bytes isdir datanum, .is current folder .. is last folder
	names = {};
	for k = 1:numel(contents),
		name = contents(k).name;
		if isdir([base_path name]) && ~strcmp(name, '.') && ~strcmp(name, '..'),
			names{end+1} = name;  %#ok
		end
	end
	
	%no sub-folders found
	if isempty(names), dataset_path = []; return; end
	
	%choice GUI 
	choice = listdlg('ListString',names, 'Name','Choose video', 'SelectionMode','single');
	
	if isempty(choice),  %user cancelled
		dataset_path = [];
	else
		dataset_path = [base_path names{choice} '/'];
	end
	
end

