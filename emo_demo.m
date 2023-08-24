function emo_demo(condition,demoNumber)

% emo_demo(condition,demoNumber)
%
% Condition can be 'C' or 'R' for Control or Reappraise
% example: emo_demo('R')
%
% Condition determines which demopic will be used

%SEED RANDOM STREAM
rng shuffle;

%clear USB connections to make sure we detect trigger
%clear PsychHID

%SET UP FOLDER LOCATIONS
basedir = pwd;  %current directory
stimfiledirectory = [basedir filesep 'stimuli'];    %where stimulus matrices are

%TIMING PREFERENCES
initialRest = 2;            %will wait this amount after trigger is received but before first task period
stimDuration = 12;          %Duration of stimulus presentation
restDuration = 4;          %Rest period between stimuli

%OPEN THE SCREEN
Screen('Preference', 'SkipSyncTests', 1);
Screen('Preference','VisualDebugLevel', 0);
[w,rect]=Screen('OpenWindow', max(Screen('screens')), 0);  %full screen
%[w,rect]=Screen('OpenWindow', max(Screen('screens')), 0,[0 0 1024 768]); %window same size as scanner screen, for testing
ifi=Screen('GetFlipInterval',w); 
Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); %turn on alpha blending for anti-aliasing

%DEFINE COLORS
black=BlackIndex(w);
white=WhiteIndex(w);
gray = [255 255 255];  % background color.  ok, its not really gray
backgroundColor = [200 200 200];
textColor = black;

%SET FONT OPTIONS
defaultFont = 'Helvetica';
Screen('TextSize',w,24);
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
fixationcolor = black;

%SCREEN LOCATION ADJUSTMENTS
picHeightAdjust = 50;   %adjust picture upward from center

%PRESENT START SCREEN - STAYS UNTIL EXPERIMENTER PRESSES ANY KEY
text = 'Press any key to begin...';
Screen('FillRect',w,backgroundColor);
DrawFormattedText(w, text, 'center','center', black); 
Screen('Flip',w);

fprintf('Press any key to begin...');
KbWait(-1);
triggerTime = GetSecs();
fprintf('Start key received\n');
BreakableWait(1);

if demoNumber == 1

    %INSTRUCTION 1
    text = 'In this experiment, you will see a series of pictures. Some of the images may be unpleasant.\n\n<press a key to continue>';
    DrawFormattedText(w,text,'center','center',black,60,[],[],1.3);
    Screen('Flip',w);
    BreakableWait(2);
    KbWait(-1);

    %INSTRUCTION 2
    text= 'After each picture, we will ask you to tell us how negative the picture made you feel. To respond, move the cursor along the scale using the 1 and 2 keys on the keyboard. The 1 key will move the slider to the left (less negative). The 2 key will move the slider to the right (more negative). You can move the slider back and forth as much as you like. When you are satisfied with your answer, press the 3 key to submit your response.\n\n<press a key to continue>';
    DrawFormattedText(w,text,'center','center',black,60,[],[],1.3);
    Screen('Flip',w);
    BreakableWait(2);
    KbWait(-1);

    %INSTRUCTION 3
    text = 'We will now practice. Press a key to begin.';
    DrawFormattedText(w,text,'center','center',black,60,[],[],1.3);
    Screen('Flip',w);
    BreakableWait(2);
    KbWait(-1);

    %SHOW PIC
    stimFolder = 'demopics';

    %READ IN PICTURE FILE
    picFilename = sprintf('%s/%s/%.2d.jpg',stimfiledirectory,stimFolder,demoNumber)
    picData = imread(picFilename);
    picTexture = Screen('MakeTexture',w,picData);
    picDims = size(picData);
    picWidth = picDims(2);
    picHeight = picDims(1);
    picLocation = [xcenter - picWidth/2, ycenter - picHeight/2 - picHeightAdjust, xcenter + picWidth/2, ycenter + picHeight/2 - picHeightAdjust];

    %DRAW PICTURE TO SCREEN
    Screen('DrawTexture',w,picTexture,[],picLocation);
    onsetTime = Screen('Flip',w);
    BreakableWait(stimDuration);

    %FOR DEBUGGING, DRAW STIMULUS NUMBER
    %debugLocation = ycenter - picHeight/2 - 70;
    %DrawFormattedText(w,num2str(captionID),'center',debugLocation,textColor);

    [responseButton, responseTime] = likert_question(w,rect,'How strongly do you feel?');

    %DRAW FIXATION FOR REST PERIOD
    Screen('FillRect',w,backgroundColor);
    Screen('DrawLines',w,fixationlines,fixationwidth,fixationcolor,[xcenter ycenter]);
    offsetTime = Screen('Flip',w);

    %WAIT FOR INTERTRIAL INTERVAL
    BreakableWait(restDuration);
    
elseif demoNumber == 2
    
    if condition == 'C'
        
        %INSTRUCTION 1
        text = 'The second part of the experiment will be just like the first. You will again see a series of pictures, and be asked to tell us how negatively each one makes you feel.\n\n<press a key to continue>';
        DrawFormattedText(w,text,'center','center',black,60,[],[],1.3);
        Screen('Flip',w);
        BreakableWait(2);
        KbWait(-1);
        
    elseif condition == 'R'
         
        %INSTRUCTION 1
        text = 'In the second part of the experiment, we want you to try to change how you feel when you see each picture by searching for an alternative interpretation of what you see. For example, you might imagine ways the situation could improve for the better, or identify aspects of the situation that are not as bad as they seem, or possibly think of what you are seeing from another perspective. Please do not look away from the picture or try to distract yourself from it. We will now look at an example together and discuss how you might change your feelings about it.\n\n<press a key to continue>';
        DrawFormattedText(w,text,'center','center',black,80,[],[],1.3);
        Screen('Flip',w);
        BreakableWait(2);
        KbWait(-1);
        
        %DRAW PICTURE TO SCREEN
        %READ IN PICTURE FILE
        stimFolder = 'demopics';
        picFilename = sprintf('%s/%s/%.2d.jpg',stimfiledirectory,stimFolder,demoNumber)
        picData = imread(picFilename);
        picTexture = Screen('MakeTexture',w,picData);
        picDims = size(picData);
        picWidth = picDims(2);
        picHeight = picDims(1);
        picHeightAdjust = 100;
        picLocation = [xcenter - picWidth/2, ycenter - picHeight/2 - picHeightAdjust, xcenter + picWidth/2, ycenter + picHeight/2 - picHeightAdjust];
        Screen('DrawTexture',w,picTexture,[],picLocation);
        
        text = 'When you see this picture, you might decide to think of this as plastic fruit, where an artist created this scene for a stock photograph. You can appreciate how the artist drew in the various discolorations on the fruit to make them appear as if they were rotting.\n\n<press a key to continue>';
        DrawFormattedText(w,text,'center',620,black,100,[],[],1.3);
        Screen('Flip',w);
        BreakableWait(5);
        KbWait(-1);
        
        %INSTRUCTION 2  
        text = 'Next, let''s practice. On the next screen, you should try to come up with an alternative way to think about the image that you see.\n\n<press a key to continue>';
        DrawFormattedText(w,text,'center','center',black,60,[],[],1.3);
        Screen('Flip',w);
        BreakableWait(2);
        KbWait(-1);
        
        %DRAW PICTURE TO SCREEN
        %READ IN PICTURE FILE
        stimFolder = 'demopics';
        picFilename = sprintf('%s/%s/03.jpg',stimfiledirectory,stimFolder)
        picData = imread(picFilename);
        picTexture = Screen('MakeTexture',w,picData);
        picDims = size(picData);
        picWidth = picDims(2);
        picHeight = picDims(1);
        picHeightAdjust = 100;
        picLocation = [xcenter - picWidth/2, ycenter - picHeight/2 - picHeightAdjust, xcenter + picWidth/2, ycenter + picHeight/2 - picHeightAdjust];
        Screen('DrawTexture',w,picTexture,[],picLocation);
        text = 'Please talk to the experimenter, and tell them how you might think about this picture in a way that reduces your negative feelings about it.';
        DrawFormattedText(w,text,'center',620,black,60,[],[],1.3);
        Screen('Flip',w);
        BreakableWait(5);
        KbWait(-1);
        
        
         BreakableWait(2);
        
    end
    
    
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
