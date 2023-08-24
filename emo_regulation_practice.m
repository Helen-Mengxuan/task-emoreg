function emo_regulation_practice(subject)

% emo_regulation_practice(subject)
%
%   subject: nonsense string
%
% example: emo_regulation_practice('goober')
%



%SEED RANDOM STREAM
rng shuffle;

%clear USB connections to make sure we detect trigger
%clear PsychHID

%SET UP FOLDER LOCATIONS
basedir = pwd;  %current directory
stimfiledirectory = [basedir filesep 'stimuli'];    %where stimulus matrices are

%TIMING PREFERENCES
initialRest = 2;            %will wait this amount after trigger is received but before first task period
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

%INSTRUCTION 1
text = 'In this experiment, you will see a series of pictures. Some of the images may be unpleasant.\n\n<press a key to continue>';
DrawFormattedText(w,text,'center','center',white,60,[],[],1.3);
Screen('Flip',w);
BreakableWait(2);
KbWait(-1);

%INSTRUCTION 2
text= 'After each picture, we will ask you to tell us how negative the picture made you feel. To respond, move the cursor along the scale using the 1 and 2 keys on the keyboard. The 1 key will move the slider to the left (less negative). The 2 key will move the slider to the right (more negative). You can move the slider back and forth as much as you like. When you are satisfied with your answer, press the 3 key to submit your response.\n\n<press a key to continue>';
DrawFormattedText(w,text,'center','center',white,60,[],[],1.3);
Screen('Flip',w);
BreakableWait(2);
KbWait(-1);
    

for trial = 1:4
    
    Screen('TextSize',w,32);
    Screen('TextFont',w,defaultFont);
    stimFolder = 'practice_pics';
    
    %designates the stimulus to be displayed
  
    if trial == 1
        guide = 'When you are prompted to Look, you should simply take in the image and try to imagine how you would feel seeing it in real life. \n\n<press a key to continue>';
        instruction = 'Look';
        instruction2 = 'Look';
        
    elseif trial == 2
        guide = 'Here''s another example.\n\n<press a key to continue>';
        instruction = 'Look';
        instruction2 = 'Look';
        
    elseif trial == 3
        guide ='When you are prompted to Reduce, you should try to change how you feel when you see each picture by searching for an alternative interpretation of what you see. For example, you might imagine ways the situation could improve for the better, or identify aspects of the situation that are not as bad as they seem, or possibly think of what you are seeing from another perspective. Please do not look away from the picture or try to distract yourself from it. We will now look at an example together and discuss how you might change your feelings about it.\n\n<press a key to continue>';
        instruction = 'Reduce';
        instruction2 = 'When you see this picture, you might decide to think of this as plastic fruit, \n created for a stock photograph. You can appreciate \n how the artist drew in the various discolorations on the fruit\n to make them appear as if they were rotting.\n\n<press a key to continue>';    
        
    elseif trial == 4
        guide ='Now let''s do a practice ''Reduce'' trial.\n\n<press a key to continue>';
        instruction = 'Reduce';
        instruction2 = 'Please talk to the experimenter, and tell them how you might \n think about this picture in a way that \nreduces your negative feelings about it.';
        
    end
    
    %READ IN PICTURE FILE
    picFilename = sprintf('%s/%s/%.2d.jpg',stimfiledirectory,stimFolder,trial);
    picData = imread(picFilename);
    picTexture = Screen('MakeTexture',w,picData);
    picDims = size(picData);
    picWidth = picDims(2)*1.3;
    picHeight = picDims(1)*1.3;
    picLocation = [xcenter - picWidth/2, ycenter - picHeight/2 - picHeightAdjust, xcenter + picWidth/2, ycenter + picHeight/2 - picHeightAdjust];
    
    %Draw Initial Guide instruction to screen before stimulus
    DrawFormattedText(w,guide,'center','center',white,60,[],[],1.3);
    Screen('Flip',w);
    BreakableWait(2);
    KbWait(-1);
    
    %DRAW PICTURE AND INSTRUCTION TO SCREEN
    Screen('DrawTexture',w,picTexture,[],picLocation);
    %switch 740 to 790 for laptop demos
    DrawFormattedText(w,instruction,'center',740,white);
    onsetTime = Screen('Flip',w);
    BreakableWait(stimDuration/2);
    
    %DRAW PICTURE AND INSTRUCTION 2 TO SCREEN
    Screen('DrawTexture',w,picTexture,[],picLocation);
    %switch 740 to 790 for laptop demos
    DrawFormattedText(w,instruction2,'center',740,white);
    onsetTime = Screen('Flip',w);
    BreakableWait(2);
    KbWait(-1);
    
    
    %FOR DEBUGGING, DRAW STIMULUS NUMBER
    %debugLocation = ycenter - picHeight/2 - 70;
    %DrawFormattedText(w,num2str(captionID),'center',debugLocation,textColor);
    
    %this is variable? Is there a time limit?
    [responseButton, responseTime] = likert_question_5(w,rect,'How negative did the picture make you feel?');
    
    %DRAW FIXATION FOR REST PERIOD
    Screen('FillRect',w,backgroundColor);
    Screen('DrawLines',w,fixationlines,fixationwidth,fixationcolor,[xcenter ycenter]);
    offsetTime = Screen('Flip',w);
     
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
