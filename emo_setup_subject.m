function emo_setup_subject(subject)

% emo_setup_subject(subject)
%
%   subject: string
%
% randomizes stimuli for affective_pictures study

%SEED RANDOM STREAM
rng shuffle;

%SET UP FOLDER LOCATIONS
basedir = pwd;  %current directory
stimfiledirectory = [basedir filesep 'stimuli'];    %where stimulus matrices are
logfiledirectory =[basedir filesep 'logfiles'];     %where log files will be saved


negativelist = Shuffle([4:33]);
neutrallist = Shuffle([1:10]);

stimlist = {};
stimlist{1}.neutral = neutrallist(1:10);
stimlist{1}.negative = negativelist(1:15);
stimlist{1}.Rnegative = negativelist(16:30);
stimlist{1}.trialtypes = Shuffle([repmat([3],[1,10]),repmat([1],[1,15]),repmat([2],[1,15])]);


filename = [logfiledirectory filesep subject '-emo-stimorder.mat'];
save(filename,'stimlist');

end