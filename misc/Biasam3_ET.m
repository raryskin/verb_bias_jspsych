%Biasam3; updated 3-27-14 by SBS

clear all
Screen('Preference','VBLTimestampingMode',-1); %This setting can be turned on if you have video driver problems.
%Screen('Preference', 'SkipSyncTests', 1); % Comment this line for real subjects
Screen('Preference', 'VisualDebuglevel', 3); %get rid of graphics check on a mac

% for this to work, just put '1' in for all of the inputs
rand('twister',sum(100*clock)) %resets the random number generator.
subject = inputnumber('Enter Subject Number only, e.g. "30", max 4 digits:', 1,9999); %EDF won't save if filename is too long.
nums=rand*50;
sran=round(nums);
srand=num2str(sran);

%% This is only relevant for the patients
% selected=0;
% while selected==0
%     startat = inputnumber('Which round do you want to start at?   ', 1,10);
%     numtrials = inputnumber('How many trials do you want to do?   ', 1,10);
%     if (numtrials+startat-1) > 10
%         error('The total number of trials in the experiment is 10');
%         startat = inputnumber('Which round do you want to start at?   ', 1,10);
%         numtrials = inputnumber('How many trials do you want to do?   ', 1,10);
%     else
%         selected=1;
%     end
% end
% endat=(numtrials+startat-1);

list = inputnumber('What list are we running today?  %Enter 1-2  ', 1,2); %note just one list for the patients

% Adjust for the current setup
pics_dir = '/Experiments/Biasam3_matlab/pics/';
sound_dir = '/Experiments/Biasam3_matlab/sounds/';
output_dir = '/Experiments/Biasam3_matlab/output/';

%Define Graphics Variables
white = [255 255 255];
black = [0 0 0];
green = [34 139 34];
grey = [0.4 0.4 0.4]; %added grey to make transparent grey text ports

textfont = 'Helvetica';
textsize = 100;

%%%%Eyetracker Stuff
commandwindow;
% AssertOSX;
% try
Screen('Preference', 'VisualDebuglevel', 3); %get rid of graphics check on a mac
if 1 Screen('Preference', 'SkipSyncTests', 0); end %The last # should be "1" for testing mode only.

% STEP 1
% Initialization of the connection with the Eyelink Gazetracker.
% exit program if this fails.
if EyelinkInit()~= 1; %
    return;
end;

% ET STEP 2
% Open a graphics window on the main screen
% using the PsychToolbox's Screen function.
screenNumber=max(Screen('Screens'));
[window, wRect]=Screen('OpenWindow', screenNumber, 0,[],32,2);
Screen(window,'BlendFunction',GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);


% ZQ - comment and uncomment, respectively, the next two lines to run in a real experiment.
[window rect] = Screen('OpenWindow',max(Screen('Screens')), black);%set up graphics (rect is the size of the window and the 0 is just to make it the window)%
%[window rect] = Screen('OpenWindow',max(Screen('Screens')),black, [0 0 640 480]);
Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); %this command enables alpha blending, which is necessary for transparent images
Screen('TextSize',window,textsize); % specify text size
Screen('TextFont',window,textfont);
Screen('TextStyle',window,0); % change default font to non-bold (necessary for windows computers)

% STEP 3
% Provide Eyelink with details about the graphics environment
% and perform some initializations. The information is returned
% in a structure that also contains useful defaults
% and control codes (e.g. tracker state bit and Eyelink key values).
el=EyelinkInitDefaults(window);

% make sure that we get gaze data from the Eyelink
Eyelink('Command', 'link_sample_data = LEFT,RIGHT,GAZE,AREA');

[v vs]=Eyelink('GetTrackerVersion');

fprintf('Experiment List_', num2str(list) );

% open file to record data to
edfFile=sprintf('%s%s%s.edf',num2str(subject),'BT',srand)';
Eyelink('Openfile', edfFile);
Eyelink('message', sprintf('SubjInfo: %s,%s,%s,%s,%s,%s,%s,%s', 'Biasam3 subject # ', num2str(subject), 'list ', num2str(list),'random # ',srand)); %Print info to top of EL file.
Eyelink('message', sprintf('SubjInfo: %s', 'This is the third Biasam experiment, with undergrads') ); %Print info to top of EL file.

% STEP 4
% Calibrate the eye tracker
EyelinkDoTrackerSetup(el);

%setup windows/drawings
%%%%
warning off MATLAB:DeprecatedLogicalAPI
warning('off','MATLAB:dispatcher:InexactMatch')

Xleft=rect(RectLeft);
Xright=rect(RectRight);
Ytop=rect(RectTop);
Ybottom=rect(RectBottom);
Xcenter=round(Xright/2);
Ycenter=round(Ybottom/2);
Xqtr=round(Xright/4);
Yqtr=round(Ybottom/4);
X3qtr=Xright-Xqtr;
Y3qtr=Ybottom-Yqtr;
piclength=round(Ybottom/5);%
Yten=round(Ybottom/18);%how far away the pics are from the top and bottom edge of screen
halfpicdist=Ycenter-piclength-Yten;%half the distance between the pictures
piclengthflux=piclength*.5; %for flux needs to be smaller
psize = [0 0 piclength piclength];

%stable ports
% TL = [Xcenter-piclength*1.5 Ycenter-piclength*1.5 Xcenter-piclength*.5 Ycenter-piclength*.5];
% TR = [Xcenter+piclength*.5 Ycenter-piclength*1.5 Xcenter+piclength*1.5 Ycenter-piclength*.5];
% LL = [Xcenter-piclength*1.5 Ycenter+piclength*.5 Xcenter-piclength*.5 Ycenter+piclength*1.5];
% LR = [Xcenter+piclength*.5 Ycenter+piclength*.5 Xcenter+piclength*1.5 Ycenter+piclength*1.5];
TL=[Xcenter-halfpicdist-piclength Ytop+Yten Xcenter-halfpicdist Ytop+Yten+piclength];
TR=[Xcenter+halfpicdist Ytop+Yten Xcenter+halfpicdist+piclength Ytop+Yten+piclength];
LL=[Xcenter-halfpicdist-piclength Ybottom-Yten-piclength Xcenter-halfpicdist Ybottom-Yten];
LR=[Xcenter+halfpicdist Ybottom-Yten-piclength Xcenter+halfpicdist+piclength Ybottom-Yten];
center = [Xcenter-200 Ycenter-200 Xcenter+200 Ycenter+200];

%Instructions
Screen('FillRect',window,black, rect)
Screen('TextSize',window,49);
WriteCentered(window, 'Welcome to the experiment. Click the mouse to begin.', Xcenter, Ycenter, white, 25);
Screen('Flip', window);
GetClicks; %Click to proceed

% Set output file
output = [output_dir,'Biasam3_',num2str(subject),'_',srand,'.txt']; %output file for naming phase
dlmwrite(output,['subject,','srand,','list,','finalorder,','trialID,','condition,','verb,','animal,','instrument,','tloc,','tiloc,','cloc,','ciloc,','inst1,','inst2,','inst3,','inst4,','RT,','clickx,','clicky,'],'delimiter','','-append');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%TESTING Instructions
Screen('FillRect',window,black, rect);
Screen('TextSize',window,49);
WriteCentered(window, 'Get ready for the next part of the experiment.', Xcenter, Ycenter, white, 25);
Screen('Flip', window);
GetClicks; %Click to proceed
Screen('Flip', window);

Screen('TextStyle', window,0);
instructions2=('-  A set of pictures will appear on your screen. You will hear some instructions to manipulate the pictures.');
instructions3=('-  For example, you might be asked to "Bathe the bear." or to "Cut the monkey''s hair", and you would act that out on the screen.');
instructions4=('-  Make sure to always click the mouse on one or more pictures to do the action. For example you might click on a pair of scissors and act out cutting the monkey''s hair.');
instructions5=('-  Or to bathe the bear you might click on the bear and pretend to bathe it.');
instructions6=('-  Once you have completed the action, right-click the mouse to move on to the next trial.');
instructions7=('-  Any questions before we get started? If not, click to start.');
WriteLine(window,instructions2, white, 100, 100, Ycenter*.25, 1.25);
WriteLine(window,instructions3, white, 100, 100, Ycenter*.50, 1.25);
WriteLine(window,instructions4, white, 100, 100, Ycenter*.75, 1.25);
WriteLine(window,instructions5, white, 100, 100, Ycenter*1.25, 1.25);
WriteLine(window,instructions6, white, 100, 100, Ycenter*1.50, 1.25);
Screen('Flip', window);
GetClicks; %click to start
WriteLine(window,instructions7, white, 100, 100, Ycenter*1.25, 1.25);
Screen('Flip', window);
GetClicks;

%List information
ListNumber = 'Biasam3testlist.txt';
fid = fopen(ListNumber);
Listbuffer = textscan(fid,'%s%s%s%s%s%s%s%s%s%s%s%s%s%s','Headerlines',2);
fclose(fid);

%Audio intros are
% "herewehave.wav"
% (f)1_CAI.wav -- competitor and mini-instrument
% (f)1_CI.wav -- competitor instrument
% (f)1_TAI.wav -- target and mini-instrument
% (f)1_TI.wav  -- target instrument
% (f)1_test.wav -- test instruction

%%%% TEST TRIALS %%%%%%
% Set Audio %%%
InitializePsychSound;
freq = 44100; % high frequency for high-quality audio recordings.
numchannels=1;
buffersize=120; % 2 minutes
audiochannel = PsychPortAudio('Open', [], 1, 1, freq, numchannels, buffersize);

startat= 1+(list-1)*81;
endat=startat+80;
counter=1;
for qq = startat:endat %testing loop
    %drift corrects in before all trials.
    EyelinkDoDriftCorrection(el);
    
    WriteLine(window,num2str(counter), white, 100, Xcenter, Ycenter, 1.25);
    Screen('Flip', window);
    WaitSecs(.5);
    
    Screen('FillRect',window,black,rect)
    Screen('Flip', window);
    HideCursor;
    
    %random locations for the four pictures
    ports={'TL', 'TR', 'LL', 'LR'};
    randports=randperm(4);
    randloc1=eval(ports{randports(1)});
    randloc2=eval(ports{randports(2)});
    randloc3=eval(ports{randports(3)});
    randloc4=eval(ports{randports(4)});
    
    %pictures
    o1=Listbuffer{10}{qq};%target
    o2=Listbuffer{11}{qq};%target instrument
    o3=Listbuffer{12}{qq};%distractor
    o4=Listbuffer{13}{qq};%distractor instrument
    
    %load pics with transparency info
    [pic1 map alpha] = imread([pics_dir, o1,'.png']);
    pic1(:,:,4) = alpha(:,:);
    [pic2 map alpha] = imread([pics_dir, o2,'.png']);
    pic2(:,:,4) = alpha(:,:);
    [pic3 map alpha] = imread([pics_dir, o3,'.png']);
    pic3(:,:,4) = alpha(:,:);
    [pic4 map alpha] = imread([pics_dir, o4,'.png']);
    pic4(:,:,4) = alpha(:,:);
    
    pic1=Screen('MakeTexture', window, pic1);%target animal
    pic2=Screen('MakeTexture', window, pic2);%target instrument
    pic3=Screen('MakeTexture', window, pic3);%competitor animal
    pic4=Screen('MakeTexture', window, pic4);%competitor instrument
    
    %info
    trialID = Listbuffer{3}{qq};
    soundID = Listbuffer{14}{qq};
    condition =Listbuffer{4}{qq};
    verb=Listbuffer{5}{qq};
    animal=Listbuffer{6}{qq};%target animal
    instrument=Listbuffer{7}{qq};%target instrument
    
    %load wav files
    targsnd=wavread([sound_dir,soundID,'_sentence1.wav']); %for real experiment
    intro=wavread([sound_dir,'herewehave.wav']);
    TAIsnd=wavread([sound_dir,soundID,'_TAI.wav']);
    TIsnd=wavread([sound_dir,soundID,'_TI.wav']);
    DAIsnd=wavread([sound_dir,soundID,'_DAI.wav']);
    DIsnd=wavread([sound_dir,soundID,'_DI.wav']);
    
    %puts picture location data in one file
    Object.textures={pic1;pic2;pic3;pic4};
    Object.coordinates={randloc1;randloc2;randloc3;randloc4};
    Object.LX = {randloc1(1);randloc2(1);randloc3(1);randloc4(1)}; %x1
    Object.LY = {randloc1(2);randloc2(2);randloc3(2);randloc4(2)}; %y1
    Object.RX = {randloc1(3);randloc2(3);randloc3(3);randloc4(3)}; %x2
    Object.RY = {randloc1(4);randloc2(4);randloc3(4);randloc4(4)}; %y2
    
    % start recording eye position
    Eyelink('startrecording');
    eye_used = -1;    %what's this?
    GetSecsStart=GetSecs;
    WaitSecs(.5); %Give us 500ms of baseline ET data before the audio and pictures start appearing.
    
    %Put up pictures to screen in random order and play audio.
    temp=randperm(4);
    introsounds={TAIsnd;TIsnd;DAIsnd;DIsnd};
    PsychPortAudio('FillBuffer', audiochannel, intro'); % here we have...
    PsychPortAudio('Start',audiochannel,1);
    PsychPortAudio('Stop',audiochannel,1);%
    
    GetSecsPic1=GetSecs;
    Screen('DrawTexture',window,Object.textures{temp(1)},[],Object.coordinates{temp(1)});
    Screen('Flip',  window);
    PsychPortAudio('FillBuffer', audiochannel, introsounds{temp(1)}');
    PsychPortAudio('Start',audiochannel,1);
    PsychPortAudio('Stop',audiochannel,1);%
    WaitSecs(.5);
    
    GetSecsPic2=GetSecs;
    Screen('DrawTexture',window,Object.textures{temp(1)},[],Object.coordinates{temp(1)});
    Screen('DrawTexture',window,Object.textures{temp(2)},[],Object.coordinates{temp(2)});
    Screen('Flip',  window);
    PsychPortAudio('FillBuffer', audiochannel, introsounds{temp(2)}');
    PsychPortAudio('Start',audiochannel,1);
    PsychPortAudio('Stop',audiochannel,1);%
    WaitSecs(.5);
    
    GetSecsPic3=GetSecs;
    Screen('DrawTexture',window,Object.textures{temp(1)},[],Object.coordinates{temp(1)});
    Screen('DrawTexture',window,Object.textures{temp(2)},[],Object.coordinates{temp(2)});
    Screen('DrawTexture',window,Object.textures{temp(3)},[],Object.coordinates{temp(3)});
    Screen('Flip',  window);
    PsychPortAudio('FillBuffer', audiochannel, introsounds{temp(3)}');
    PsychPortAudio('Start',audiochannel,1);
    PsychPortAudio('Stop',audiochannel,1);%
    WaitSecs(.5);
    
    GetSecsPic4=GetSecs;
    Screen('DrawTexture',window,Object.textures{temp(1)},[],Object.coordinates{temp(1)});
    Screen('DrawTexture',window,Object.textures{temp(2)},[],Object.coordinates{temp(2)});
    Screen('DrawTexture',window,Object.textures{temp(3)},[],Object.coordinates{temp(3)});
    Screen('DrawTexture',window,Object.textures{temp(4)},[],Object.coordinates{temp(4)});
    Screen('Flip',  window);
    PsychPortAudio('FillBuffer', audiochannel, introsounds{temp(4)}');
    PsychPortAudio('Start',audiochannel,1);
    PsychPortAudio('Stop',audiochannel,1);%
    
    ShowCursor('Hand');
    WaitSecs(1);
    
    %Start test audio
    PsychPortAudio('FillBuffer', audiochannel, targsnd');
    %pahandle = PsychPortAudio('Open' [, deviceid][, mode][, reqlatencyclass][,freq][, channels][, buffersize][, suggestedLatency][, selectchannels]);
    % The first # (3) is for ASIO sound card.
    % The second # is 2 for recording mode; 1 is for playback, 3 is for
    % BOTH. The second number =1 is to force it to do fast timing.
    
    %[VBLTimestamp StimulusOnsetTime FlipTimestamp Missed Beampos] =Screen('Flip',  window);
    GetSecsTgt=GetSecs;
    PsychPortAudio('Start',audiochannel,1);
    %sends condition info to Eyetracker. The screen line needs to go "port,picture;port,picture...".
    %The .asc conversion has a limit on how long this line can be. So, for my 10 ports this is close to the max line length.
    Eyelink('message', sprintf('Screen: %s,%s;%s,%s;%s,%s;%s,%s',o1, ports{randports(1)},o2,ports{randports(2)},o3,ports{randports(3)},o4,ports{randports(4)}));
    %the stimuli message is what goes to the auditory stimuli table in Access. I usually put my condition information here.
    Eyelink('message', sprintf('Stimuli: %s,%s,%s', trialID, condition, o1) ); %max this is off by 16ms from my getsecs estimates from ET start to here.
    
    WaitSecs(1);
    
    t = 1;
    selected=0;
    clicky=0;
    while selected==0
        %Record mouse events to move pics
        [z,w,buttons]=GetMouse(window);
        for p = (1:4)
            zold=Object.LX{p};
            wold=Object.LY{p};
            if (z>Object.LX{p} & z<Object.RX{p}) & (w>Object.LY{p} & w<Object.RY{p})& buttons(1)==1;
                whiteout{t} = Object.coordinates{p};
                while buttons(1)==1
                    [z,w,buttons] = GetMouse(window);
                    if clicky == 0
                        xclicky=z;
                        yclicky=w;
                        clicky=1;
                    end
                    if z> rect(3)
                        z=rect(3); % xmax
                    end;
                    
                    if w> rect(4)
                        w=rect(4); %ymax
                    end
                    
                    %changes the fluxwindow, fills in the old location of the object,
                    %writes new object location
                    %get the old location information
                    coord=[z-piclengthflux w-piclengthflux z+piclengthflux w+piclengthflux];
                    if coord(1) < rect(1)
                        coord(1)=rect(1);
                    end
                    if coord(2) < rect(2)
                        coord(2)=rect(2);
                    end
                    if coord(3) > rect(3)
                        coord(3)=rect(3);
                    end
                    if coord(4) > rect(4)
                        coord(4)=rect(4);
                    end
                    
                    %get the new location information
                    coord2=[z-piclengthflux w-piclengthflux z+piclengthflux w+piclengthflux];
                    if coord2(1) < rect(1)
                        coord2(1)=rect(1);
                    end
                    if coord2(2) < rect(2)
                        coord2(2)=rect(2);
                    end
                    if coord2(3) > rect(3)
                        coord2(3)=rect(3);
                    end
                    if coord2(4) > rect(4)
                        coord2(4)=rect(4);
                    end
                    
                    zold=z;
                    wold=w;
                    Object.LX{p} = z-piclengthflux; %these were 80 (10 pixels smaller than picsize)
                    Object.RX{p} = z+piclengthflux;
                    Object.LY{p} = w-piclengthflux;
                    Object.RY{p} = w+piclengthflux;
                    Object.coordinates{p} = [z-piclengthflux w-piclengthflux z+piclengthflux w+piclengthflux];
                    if Object.coordinates{p}(1)<rect(1);
                        Object.coordinates{p}(1)=rect(1);
                    end
                    
                    if Object.coordinates{p}(2)<rect(2);
                        Object.coordinates{p}(2)=rect(2);
                    end
                    if Object.coordinates{p}(3)>rect(3);
                        Object.coordinates{p}(3)=rect(3);
                    end
                    if Object.coordinates{p}(4)>rect(4);
                        Object.coordinates{p}(4)=rect(4);
                    end
                    
                    for iDraw = 1:4
                        Screen('DrawTexture',window,Object.textures{iDraw},[],Object.coordinates{iDraw});
                    end
                    Screen('Flip',  window);
                    
                end;
            end;
        end;
        
        if buttons(2)== 1;
            GetSecsTgt2=GetSecs;
            selected = 1;
            WaitSecs(1);
        end;
        
    end; %End of tgt loop; stop recording eye-movements,
    
    RT=GetSecsTgt2-GetSecsTgt; %RT from audio onset until click
    
    Screen('FillRect',window,black,rect);
    Screen('Flip',window, 1); % don't erase!!!!
    PsychPortAudio('Stop',audiochannel,1);%
    
    temp = [num2str(subject), ',',srand,',',num2str(list),',',num2str(counter),',',trialID,',',condition,',',verb,',',animal,',',instrument,',',ports{randports(1)},',',ports{randports(2)},',',ports{randports(3)},',',ports{randports(4)},',',num2str(GetSecsPic1),',',num2str(GetSecsPic2),',',num2str(GetSecsPic3),',',num2str(GetSecsPic4),',',num2str(RT),',',num2str(xclicky),',',num2str(yclicky)];
    dlmwrite(output,temp,'delimiter','','-append');
    
    Eyelink('stoprecording');
    counter=counter+1;
end %test loop


PsychPortAudio('Close', audiochannel);
Eyelink('closefile');
Eyelink('shutdown');

Screen('CloseAll');

