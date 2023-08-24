function [response,responseTime] = likert_question(w,rect,text)

    response = 0;
    responseTime = 0.0;
    
    %SAVE SCREEN DIMENSIONS
    screenX = rect(3);
    screenY = rect(4);
    xcenter = screenX/2; 
    ycenter = screenY/2;
    
    barYcenter = ycenter + 200;
    barXcenter = xcenter;

    %DEFINE COLORS
    black = [0 0 0];
    white = [255 255 255];
    gray  = [200 200 200];
    defaultFont = 'helvetica';
    backgroundColor = gray;
    textColor = white;
    
    %DEFINE FIXATION CROSS
    fixationsize = 8;
    fixationlines = [-fixationsize-1 fixationsize 0 0;0 0 -fixationsize fixationsize];
    fixationwidth = 1;
    fixationcolor = black;
    
    %DRAW FIXATION AND WAIT INTERTRIAL REST PERIOD
    Screen('FillRect', w,backgroundColor); 
    Screen('DrawDots',w,[0;0],10,black,[xcenter,ycenter],2);
    Screen('Flip',w);
    
    %SET TEXT DEFAULTS
    textSize = 18;
    questionSize = 36;
    textFont = 'Helvetica';
    Screen('TextSize',w,textSize);
    Screen('TextFont',w,textFont);
    wrapat = 40;
    vspacing = 1.2;
    
    %DEFINE SIZE OF BAR
    barLength = 360;
    barHeight = 20;
    barNumUnits = 5;
    barNumUnitsOneSide = (barNumUnits - 1)/2;
    barColor = [0 155 0];
    
    %Draw slider bar
    Screen('FillRect', w,backgroundColor); 
    Screen('FillRect',w,barColor,[barXcenter-barLength/2 barYcenter-barHeight/2 barXcenter+barLength/2 barYcenter+barHeight/2]);
    
    %Add tick marks
    tickHeight = 30;
    tickColor = black;
    tickWidth = 2;
    
    leftmost = barXcenter-barLength/2;
    increment = (barLength/(barNumUnits-1));
    
    fromY = barYcenter-tickHeight/2;
    toY = barYcenter+tickHeight/2;
    
    xpoints = 0:barNumUnits-1;
    xpoints = xpoints*increment + barXcenter-barLength/2;
    xpoints = sort([xpoints xpoints]);
    ypoints = repmat([barYcenter-tickHeight/2 barYcenter+tickHeight/2],1,barNumUnits);
    lines = [xpoints;ypoints];
    
    Screen('DrawLines',w,lines,tickWidth,tickColor);
    
    %Add tickmark labels
    labelColor = black;
    labels = num2str([1:barNumUnits],'%d');
    
    x=leftmost;
    y=barYcenter + barHeight + 10;
    for i = 1:barNumUnits
       width=RectWidth(Screen('TextBounds',w,num2str(i)));
       x = x-width/2;
       Screen('DrawText',w,num2str(i),x,y,labelColor);
       x = x+width/2;
       x = x + increment;
       
    end
    
    %Add endpoint keys
    textColor = black;
    keySize = 18;
    leftkeytext = 'Not strong';
    rightkeytext = 'Very strong';
    Screen('TextSize',w,keySize);
    leftx = xcenter - barLength/2 - 20 -  RectWidth(Screen('TextBounds',w,leftkeytext));
    rightx = xcenter + barLength/2 + 20;
    
    Screen('DrawText',w,leftkeytext,leftx,barYcenter,textColor);
    Screen('DrawText',w,rightkeytext,rightx,barYcenter,textColor);
    
    %Add slider
    sliderColor = [0 0 200];
    sliderNotch = 1;
    sliderWidth = 20;
    sliderHeight=40;
    
    sliderLeftX = leftmost + (sliderNotch-1)*increment - sliderWidth/2;
    sliderRightX = leftmost + (sliderNotch-1)*increment + sliderWidth/2;
    sliderTopY = barYcenter-sliderHeight/2;
    sliderBottomY = barYcenter+sliderHeight/2;
    
    Screen('FillRect',w,sliderColor,[sliderLeftX sliderTopY sliderRightX sliderBottomY]);
    
    
    %Draw text
    Screen('TextStyle',w,1); 
    Screen('TextSize',w,questionSize);
    DrawFormattedText(w, text, 'center','center',textColor, wrapat,[],[],vspacing,[],rect);
    Screen('TextSize',w,textSize);
    Screen('TextStyle',w,0); 
    
    %Show it
    startTime = Screen('Flip',w);
    
    
    %Wait for keypresses
    maxTime = 5;
    precision = 1;
    
    doneCode = KbName('3#');
    downCode=KbName('1!');
    upCode=KbName('2@');
    
    while GetSecs - startTime <=maxTime
        
             [ keyIsDown, timeSecs, keyCode ] = KbCheck(-1);
             if keyIsDown
                 index=find(keyCode);
                 if (length(index) > 1)
                     %multiple keys were pressed
                     %ignore
                 else
                     if (index==doneCode)
                         sliderColor = [0 0 50];
                         
                         %Draw slider bar
                         Screen('FillRect', w,backgroundColor); 
                         Screen('FillRect',w,barColor,[barXcenter-barLength/2 barYcenter-barHeight/2 barXcenter+barLength/2 barYcenter+barHeight/2]);
                         %ticks
                         Screen('DrawLines',w,lines,tickWidth,tickColor);
                         %labels
                         Screen('TextSize',w,textSize);
                         x=leftmost;
                         for i = 1:barNumUnits
                           width=RectWidth(Screen('TextBounds',w,num2str(i)));
                           x = x-width/2;
                           Screen('DrawText',w,num2str(i),x,y,labelColor);
                           x = x+width/2;
                           x = x + increment;
                          
                        end
                        Screen('TextSize',w,keySize);
                        Screen('DrawText',w,leftkeytext,leftx,barYcenter,textColor);
                        Screen('DrawText',w,rightkeytext,rightx,barYcenter,textColor);   
                        sliderLeftX = leftmost + (sliderNotch-1)*increment - sliderWidth/2;
                        sliderRightX = leftmost + (sliderNotch-1)*increment + sliderWidth/2;

                        Screen('FillRect',w,sliderColor,[sliderLeftX sliderTopY sliderRightX sliderBottomY]);

                        %Draw text
                        Screen('TextStyle',w,1); 
                        Screen('TextSize',w,questionSize);
                        DrawFormattedText(w, text, 'center','center',textColor, wrapat,[],[],vspacing,[],rect);
                        Screen('TextSize',w,textSize);
                        Screen('TextStyle',w,0); 
                        
                        %Show it
                        Screen('Flip',w);
                         
                        response = sliderNotch;
                        responseTime = timeSecs - startTime;
                         
                        break;
                     end
                     if (index==upCode || index==downCode)
                         
                         if index==upCode
                       
                            if (sliderNotch < barNumUnits)
                              sliderNotch = sliderNotch + precision;
                            end
                         elseif index==downCode
                              
                            if (sliderNotch > 1)
                              sliderNotch = sliderNotch - precision;
                            end
                         end
                   
    
                         %Draw slider bar
                         Screen('FillRect', w,backgroundColor); 
              
                         Screen('FillRect',w,barColor,[barXcenter-barLength/2 barYcenter-barHeight/2 barXcenter+barLength/2 barYcenter+barHeight/2]);
                         %ticks
                         Screen('DrawLines',w,lines,tickWidth,tickColor);
                         %labels
                         Screen('TextSize',w,textSize);
                         x=leftmost;
                         for i = 1:barNumUnits
                           width=RectWidth(Screen('TextBounds',w,num2str(i)));
                           x = x-width/2;
                           Screen('DrawText',w,num2str(i),x,y,labelColor);
                           x = x+width/2;
                           x = x + increment;
                           
                        end
                        Screen('TextSize',w,keySize);
                        Screen('DrawText',w,leftkeytext,leftx,barYcenter,textColor);
                        Screen('DrawText',w,rightkeytext,rightx,barYcenter,textColor);   
                        sliderLeftX = leftmost + (sliderNotch-1)*increment - sliderWidth/2;
                        sliderRightX = leftmost + (sliderNotch-1)*increment + sliderWidth/2;

                        Screen('FillRect',w,sliderColor,[sliderLeftX sliderTopY sliderRightX sliderBottomY]);

                        
                        %Draw text
                        Screen('TextStyle',w,1); 
                        Screen('TextSize',w,questionSize);
                        DrawFormattedText(w, text, 'center','center',textColor, wrapat,[],[],vspacing,[],rect);
                        Screen('TextSize',w,textSize);
                        Screen('TextStyle',w,0); 
                        
                        %Show it
                        Screen('Flip',w);           
                        response = sliderNotch;
                         
                        WaitSecs(.2); %to get discreet keypress
                         
                     end
                     
                 end
 
             end
    end
   
    
    %fprintf('Final likert decision: %i\n',sliderNotch);

end
