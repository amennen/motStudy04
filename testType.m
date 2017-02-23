% Example 1 - shows key-response times from visual onset 
% written for Psychtoolbox 3  by Aaron Seitz 1/2012
    DEBUG_MONITOR_SIZE = [700 500];
        windowSize.pixels = DEBUG_MONITOR_SIZE;
    [mainWindow, null] = Screen('OpenWindow',0,[0 0 0],[0 0 windowSize.pixels]);
 textColor = [255 255 255];
 bgColor = [0 0 0];
KbName('UnifyKeyNames'); %used for cross-platform compatibility of keynaming
KbQueueCreate; %creates cue using defaults
KbQueueStart;  %starts the cue
msg = 'type please';
% Write the message
Length = windowSize.pixels(1);
    Screen('DrawText', mainWindow, msg, windowSize.pixels(1)/2, windowSize.pixels(2)/2, textColor, bgColor);
    Screen('DrawLine',mainWindow,[0 0 0], 640, (Length*150)+140, 1040 ,(Length*150)+140, 5);
  Screen('Flip', mainWindow, 0, 1);
string = '';
x = windowSize.pixels(1)/2;
y = windowSize.pixels(2)/2 + 5;
WaitSecs(2)
while true
  char = GetChar;
  switch (abs(char))
      case {13, 3, 10}
          % ctrl-C, enter, or return
          break;
          case 8
            % backspace
              if ~isempty(string)
                  string = string(1:length(string)-1);
              end
          otherwise
              string = [string, char];
      end
    output = [msg, ' ', string]; 
    Screen('DrawText', mainWindow, msg, x, y, textColor, bgColor);
    Screen('DrawLine',mainWindow,[0 0 0], 640, (Length*150)+140, 1040 ,(Length*150)+140, 5);
    Screen('Flip', mainWindow, 0, 1);
    Screen('DrawText', mainWindow, string, 650, (Length*150)+40, textColor, bgColor);
    Screen('Flip', mainWindow);
end
string = GetEchoString(mainWindow,msg,[],[],[255 255 255],[0 0 0])