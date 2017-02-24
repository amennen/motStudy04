% Example 1 - shows key-response times from visual onset 
% written for Psychtoolbox 3  by Aaron Seitz 1/2012
DEBUG_MONITOR_SIZE = [700 500];
windowSize.pixels = DEBUG_MONITOR_SIZE;
windowSize.degrees = [35 30];
windowSize.degrees_per_pixel = windowSize.degrees ./ windowSize.pixels;

[mainWindow, null] = Screen('OpenWindow',0,[0 0 0],[0 0 windowSize.pixels]);
textColor = [255 255 255];
bgColor = [0 0 0];
KbName('UnifyKeyNames'); %used for cross-platform compatibility of keynaming
KbQueueCreate; %creates cue using defaults
KbQueueStart;  %starts the cue

% you can check the code of the key with KbName('delete') etc.
returnKey=40; %define return key (used to end)
deleteKey=42; %define delete key (used to delete)
spaceKey=44;
periodKey=55;
quoteKey=52;
%shifts=[225 229];
instructions = 'Type some text. Press ENTER to finish typing.';

Screen('TextSize',mainWindow,20); %sets textsize for instructions
[nx,nyi] = DrawFormattedText(mainWindow,instructions, 'center', [], textColor);
colors.GREY = [150 150 150];
square_col = colors.GREY;
bumper_size = 0;
CENTER = windowSize.pixels/2;
stim.square_dims = round([20 20] ./ mean(windowSize.degrees_per_pixel)); % 
square_bounds = [CENTER-(stim.square_dims/2) CENTER+(stim.square_dims/2)-1];
Screen('FillRect', mainWindow, square_col, square_bounds)
Screen('Flip',mainWindow);

ListenChar(2)
%HideCursor();
enterpressed=0; %initializes loop flag
AsteriskBuffer=[]; %initializes buffer
WRAPCHARS = 70;
% special cases: periods don't put the ">" and the shift key (numbers come
% up with symbols too hmm
% also want it so that when reach the end of the window it moves to the
% next line

while ( enterpressed==0 )
    [ pressed, firstPress]=KbQueueCheck; %checks for keys
    enterpressed=firstPress(returnKey);%press return key to terminate each response
    if (pressed && ~enterpressed) %keeps track of key-presses and draws text
        if firstPress(deleteKey) %if delete key then erase last key-press
            AsteriskBuffer=AsteriskBuffer(1:end-1); %erase last key-press
        elseif firstPress(spaceKey)
            % we want to add a space instead of writing space lol
            AsteriskBuffer=[AsteriskBuffer ' '];
        elseif firstPress(periodKey)
            AsteriskBuffer=[AsteriskBuffer '.'];
        elseif firstPress(quoteKey)
            AsteriskBuffer=[AsteriskBuffer  '"' ];
        else %otherwise add to buffer
           firstPress(find(firstPress==0))=NaN; %little trick to get rid of 0s
          [endtime Index]=min(firstPress); % gets the RT of the first key-press and its ID
            AsteriskBuffer=[AsteriskBuffer KbName(Index)]; %adds key to buffer
        end        
        %Screen('DrawText', mainWindow,'Type some text. Press ENTER to finish typing.',windowSize.pixels(1)/2-300,windowSize.pixels(2)/2-300,textColor,bgColor); %draws instructions
        %Screen('TextSize',mainWindow,10);  %sets textsize for keys pressed
        %[nx,ny,textbounds] = DrawFormattedText(mainWindow, AsteriskBuffer, 'left',nyi+20,textColor,WRAPCHARS); %draws keyspressed, last after color is to wrap text
        %Screen('FrameRect', mainWindow, [100 100 100], textbounds)
        %Screen('FillRect', mainWindow, [100 100 100], textbounds)
        Screen('TextSize',mainWindow,20); %sets textsize for instructions
        [nx,nyi] = DrawFormattedText(mainWindow,instructions, 'center', [], textColor);
        Screen('FillRect', mainWindow, square_col, square_bounds)
        Screen('TextSize',mainWindow,10); 
        [nx,ny,textbounds] = DrawFormattedText(mainWindow, AsteriskBuffer, 'left',nyi+20,textColor,WRAPCHARS);
        Screen('Flip',mainWindow);
    end;
    WaitSecs(.01); % put in small interval to allow other system events
end
ListenChar(0); %makes it so characters typed do show up in the command window
ShowCursor(); %shows the cursor