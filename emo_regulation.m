function emo_regulation(subject,run)

% emo_regulation(subject,run)
%
%   subject: string
%   run: integer
%
% example: emo_regulation('S01',1)
%
% must run setup_subject first


%SEED RANDOM STREAM
rng shuffle;

%clear USB connections to make sure we detect trigger
%clear PsychHID

%SET UP FOLDER LOCATIONS
basedir = pwd;  %current directory
stimfiledirectory = [basedir filesep 'stimuli'];    %where stimulus matrices are
logfiledirectory =[basedir filesep 'logfiles'];     %where log files will be saved

%LOAD STIMULUS ORDERS
orderfile = [logfiledirectory filesep subject '-emo-stimorder.mat'];
if exist(orderfile) ~= 2
    fprintf('\nSubject order file not found. Please run setup_subject for this subject before running this script.\n\n');
    return;
end
load(orderfile);
stimlist = stimlist{run};
numTrials = length(stimlist.trialtypes);

%TIMING PREFERENCES
initialRest = 6;            %will wait this amount after trigger is received but before first task period
stimDuration = 8;          %Duration of stimulus presentation
%stimDuration = 2;          %debug mode
restDurationmean = 3;          %Rest period between stimuli

%OPEN THE SCREEN
Screen('Preference', 'SkipSyncTests', 1);
Screen('Preference','VisualDebugLevel', 0);
[w,rect]=Screen('OpenWindow', max(Screen('screens')), 0);  %full screen
%[w,rect]=Screen('OpenWindow', max(Screen('screens')), 0,[0 0 1024 768]); %window same size as scanner screen, for testing
ifi=Screen('GetFlipInterval',w); 
Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); %turn on alpha blending for anti-aliasing

%SET UP LOG FILE 
logfilename = [logfiledirectory filesep subject '-sess' num2str(run) '-emoreg-log.txt'];
logfile = fopen(logfilename,'a'); 
fprintf('Opening logfile: %s\n',logfilename); 
fprintf(logfile,'## LOG FOR SUBJECT %s SESSION %d\n',subject,run); 
fprintf (logfile, '## %s\n',datestr(now));
fprintf(logfile,'##StimID\tStimType\tOnset\tOffset\tResponse\tResptime\n');

%DEFINE COLORS
black=BlackIndex(w);
white=WhiteIndex(w);
gray = [255 255 255];  % background color.  ok, its not really gray
backgroundColor = [0 0 0];
textColor = white;

%SET FONT OPTIONS
defaultFont = 'Helvetica';
Screen('TextSize',w,32);
Screen('TextFont',w,defaultFont);
wrapAt = 80;

%SAVE SCREEN DIMENSIONS
screenX = rect(3);
screenY = rect(4);
xcenter = screenX/2; 
ycenter = screenY/2;

%DEFINE FIXATION CROSS
fixationsize = 8;
fixationlines = [-fixationsize-1 fixationsize 0 0;0 0 -fixationsize fixationsize];
fixationwidth = 2;
fixationcolor = gray;

%SCREEN LOCATION ADJUSTMENTS
picHeightAdjust = 0;   %adjust picture upward from center

%WAIT FOR SCANNER TRIGGER
text = 'We will start shortly ...';
Screen('FillRect',w,backgroundColor);
DrawFormattedText(w, text, 'center','center', white); 
Screen('Flip',w);

fprintf('Waiting for scanner trigger...');
triggerCode=KbName('5%');   %Set scanner trigger key here

while 1
    [ keyIsDown, timeSecs, keyCode ] = KbCheck(-1);
    if keyIsDown  
        index=find(keyCode);
        if (index==triggerCode)
            break;   
        end
    end
end
triggerTime = timeSecs;
fprintf('Trigger received\n');

%SHOW FIXATION FOR INITIAL REST
Screen('FillRect',w,backgroundColor);
Screen('DrawLines',w,fixationlines,fixationwidth,fixationcolor,[xcenter ycenter]);
timeSecs = Screen('Flip',w);
BreakableWait(initialRest);  

Rnegativetrial = 1;
negativetrial = 1;
neutraltrial = 1;

%need to add instruction text within each trial

for trial = 1:numTrials
    
    Screen('TextSize',w,32);
    Screen('TextFont',w,defaultFont);
    
    %designates the stimulus to be displayed
    trialtype = stimlist.trialtypes(trial);
    if trialtype == 1
        stimFolder = 'NegativeImages';
        stimID = stimlist.Rnegative(Rnegativetrial);
        Rnegativetrial = Rnegativetrial + 1;
        stimType = 'Rnegative';
        instruction= 'Reduce';
    elseif trialtype == 2
        stimFolder = 'NegativeImages';
        stimID = stimlist.negative(negativetrial);
        negativetrial = negativetrial + 1;
        stimType = 'negative';
        instruction= 'Look';
    else
        stimFolder = 'NeutralImages';
        stimID = stimlist.neutral(neutraltrial);
        neutraltrial = neutraltrial + 1;
        stimType = 'neutral';
        instruction= 'Look';
    end
    
    fprintf('Trial %d\ttrialtype %d\tstimType %s\tInstruction %s ',trial,trialtype,stimType,instruction);
    
    %READ IN PICTURE FILE
    picFilename = sprintf('%s/%s/%.2d.jpg',stimfiledirectory,stimFolder,stimID);
    picData = imread(picFilename);
    picTexture = Screen('MakeTexture',w,picData);
    picDims = size(picData);
    picWidth = picDims(2)*1.3;
    picHeight = picDims(1)*1.3;
    picLocation = [xcenter - picWidth/2, ycenter - picHeight/2 - picHeightAdjust, xcenter + picWidth/2, ycenter + picHeight/2 - picHeightAdjust];
    
    %DRAW PICTURE AND INSTRUCTION TO SCREEN
    Screen('DrawTexture',w,picTexture,[],picLocation);
    DrawFormattedText(w,instruction,'center',740,white);
    onsetTime = Screen('Flip',w);
    BreakableWait(stimDuration);
    
    %FOR DEBUGGING, DRAW STIMULUS NUMBER
    %debugLocation = ycenter - picHeight/2 - 70;
    %DrawFormattedText(w,num2str(captionID),'center',debugLocation,textColor);
    
    %this is variable? Is there a time limit?
    [responseButton, responseTime] = likert_question_5(w,rect,'How negative did the picture make you feel?');
    
    %DRAW FIXATION FOR REST PERIOD
    Screen('FillRect',w,backgroundColor);
    Screen('DrawLines',w,fixationlines,fixationwidth,fixationcolor,[xcenter ycenter]);
    offsetTime = Screen('Flip',w);
     
    %WRITE OUT TO LOG FILE
    fprintf(' Response %d made at time %.2f\n',responseButton,responseTime);
    fprintf(logfile,'%d\t%s\t%.3f\t%.3f\t%d\t%.3f\n',stimID,stimType,onsetTime-triggerTime,offsetTime-triggerTime,responseButton,responseTime);
    
    %WAIT FOR INTERTRIAL INTERVAL
    restDuration=restDurationmean+(rand(1)*2);
    BreakableWait(restDuration);
   
   
end
 sca;

end


function BreakableWait(secs)

    startTime = GetSecs;
    breakKey = KbName('Escape');

    while (GetSecs-startTime < secs)
        [ keyIsDown, timeSecs, keyCode ] = KbCheck(-1);
        if keyIsDown
            if(find(keyCode)==breakKey)
                sca;
                error('Exiting: user pressed escape.');
            end
        end
    end

end
