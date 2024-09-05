%% WM Orientation Retro-cue Validity Task
% 26 June 2023, SisiWang
% V1-with no neutral cue

%% Close Serial Port
%     fclose(SerialPortObj);

%% Practice
clear;clc;
Screen('Preference','SkipSyncTests',1);

%% get subinfo
Serial_port = input('Have you checked the Serial Port connection?  yes/no   ', 's');
SubNo = input ('Please input subject number (start with 11):  ');
PartNo = input ('Please input part number ((part0-0)):  ');
Prac = input('Are you sure this is Practice?  yes/no   ', 's');
room = input('Are you running in Room EEG-B?  yes/no   ', 's');

PartNo = 0;

% Subinfo.gender = input ('Please input subject gender(1-Female/2-Male/3-Other):  ');
% Subinfo.age = input ('Please input subject age:  ');


%% set Eyelink
dummymode = 0; %Added for eyelink testing
asw = input('Do you want to start eye-tracking, yes or no?    ',  's');
if strfind(asw, 'yes') == 1
    Eyetracking=1;
else
    Eyetracking=0;
end
%%%-----------------------------------------------------------------------------------------
Parameter.Eyelink = Eyetracking;

%% set EEG
eeg_re = input('Do you want to start EEG-recording, yes or no?    ',  's');
if strfind(eeg_re, 'yes') == 1
    EEGrecording=1;
else
    EEGrecording=0;
end
%%%-----------------------------------------------------------------------------------------
Parameter.EEGrecording = EEGrecording;


%% set EEG-serial port
% go to 'Device Manage' to check USB port name
if EEGrecording

    % eeg-b
    if strfind(room, 'yes') == 1
        SerialPortObj = serial('COM8', 'baudRate', 115200);  % !!! go to 'Device Manage' to check USB port name
    else
        SerialPortObj = serial('COM4', 'baudRate', 115200);  % !!! go to 'Device Manage' to check USB port name
    end
    
    % eye-a
%     SerialPortObj = serial('COM4', 'baudRate', 115200);  % !!! go to 'Device Manage' to check USB port name

    SerialPortObj.BytesAvailableFcnMode='byte';
    SerialPortObj.BytesAvailableFcnCount=1;
    SerialPortObj.BytesAvailableFcn=@ReadCallback;
    % To connect the serial port object with serial port hardware
    fopen(SerialPortObj);%open the port
end

%% set EEG triggers
fixEEGTrig = 10;
samEEGTrig = 20;
delay1EEGTrig = 30;
cuesideEEGTrig = [41 42]; % 41-left, 42-right
cuetypeEEGTrig = [51 52]; % 51-valid, 52-invalid
% delay2EEGTrig = [51 52];
testonEEGTrig = 60;
respEEGTrig = 70;
itiEEGTrig = 80;


%% SET PARAMETERS
% Screen resolution & screen-sit distance
% scrreso =1728; % 1728*1117 % sisimacbook16inch
% scrwid =35; % in cm
scrreso = 1920; % 1920*1080
scrwid = 53; %cm

scrdis = 75; %cm

% get parameters for stimuli
[param] = recuevalid_v1_getStimParams(scrreso,scrwid,scrdis); % get some user-defined parameters


%% initialize and set up screen & psychtoolbox
Screens = Screen('Screens');
scr.nmbr  = max(Screens);
HideCursor;
ListenChar(2); % we don't want the pressed keys to appear in Matlab from this point on
Priority(0); % high priority om Windows machines
scr.color = [128 128 128];


% scr.wrect = [0, 0, 1728, 1117];
scr.wrect = [0, 0, 1920, 1080];
[scr.wptr,scr.wrect] = Screen ('OpenWindow', scr.nmbr, scr.color, scr.wrect);


[scr.xc,scr.yc] = RectCenterd(scr.wrect);
scr.center = [scr.xc, scr.yc];


%% set experimental parameters
% load pre-set block sequence
% 1-100%, 2-80%, 3-60%, 4-100%-testblack
load('v1_SessSeq_BlkSeq.mat')
% BlkSeq_cp = BlkSeq(SubNo-10,:); 
BlkSeq_cp = [1 1 1]; % for practice only

% get trial parameters
PartNo = PartNo+1;

if BlkSeq_cp(PartNo) == 1 
    [deg_matrix,deg_matrix_label] = recuevalid_v1_getTrialParams_100valid;
elseif BlkSeq_cp(PartNo) == 2
    [deg_matrix,deg_matrix_label] = recuevalid_v1_getTrialParams_80valid;
elseif BlkSeq_cp(PartNo) == 3
    [deg_matrix,deg_matrix_label] = recuevalid_v1_getTrialParams_60valid;
end

% TrialNum = size(deg_matrix,1);
TrialNum = 20;


%% set break time
break_after = 50;


%% quit program
quit_key = 'esc'; %% press this button after any response to quit the experiment


%% set up eye tracker
[scr.width, scr.height]=Screen('WindowSize', 0);
if Eyetracking
    el=EyelinkInitDefaults(scr.wptr); %w is optional param, this is to send pixel coordinates to eyelink
    % set eyelink mode
    if ~EyelinkInit(dummymode)
        fprintf('Eyelink Init aborted.\n');
        return;
    end

    % get eyelink version
    [v vs]=Eyelink('GetTrackerVersion');
    fprintf('Running experiment on a ''%s'' tracker.\n', vs );

    % send some commands to eyetracker
    Eyelink('Command', 'link_sample_data  = GAZE,GAZERES,HREF,PUPIL,AREA,STATUS,INPUT');
    Eyelink('Command', 'link_event_data = GAZE,GAZERES,HREF,AREA,VELOCITY,STATUS,FIXAVG,NOSTART');
    Eyelink('Command', 'link_event_filter  = LEFT,RIGHT,FIXATION,FIXUPDATE,SACCADE,BLINK,MESSAGE,INPUT');
    Eyelink('Command', 'file_sample_data  = LEFT,RIGHT,GAZE,GAZERES,AREA,STATUS,INPUT');
    % Eyelink('Command', 'screen_pixel_coords = %ld %ld %ld %ld', 1000, 200,scnPix(1)-400,scnPix(2)-200);%change the calibration coordinate
    %     Eyelink('command', ['screen_distance = ' num2str(topViewDist) ' ' num2str(bottomViewDist)]); % ??? top and bottom screen distance ???
    Eyelink('command', 'screen_pixel_coords = %ld %ld %ld %ld', 0, 0, scr.width-1, scr.height-1);
    Eyelink('message', 'DISPLAY_COORDS %ld %ld %ld %ld', 0, 0, scr.width-1, scr.height-1);
    el.backgroundcolour = scr.color;
    el.msgfontcolour = [0 0 0]; % black
    el.calibrationtargetcolour = [0 0 0];
    el.cal_target_beep = [1250 0 0.05];
    el.drift_correction_target_beep = [1250 0 0.05];
    el.calibration_failed_beep = [400 0 0.25];
    el.drift_correction_failed_beep = [400 0 0.25];
    el.drift_correction_success_beep = [800 0 0.25];%[800 0.8 0.25]%set off drift correction beep
    el.drift_correction_failed_beep = [400 0 0.25];
    el.drift_correction_success_beep = [800 0 0.25];
    el.calibrationtargetsize = 1.00;%inner size
    el.calibrationtargetwidth = 0.25;%outer size
    % change the calibration coordinates
    calibxy = [960 540; 660 540; 1260 540; 960 240; 960 840; 660 240; 560 840; 1260 840; 1260 240];%9 dots for calibration
    if exist('calibxy','var') && isnumeric(calibxy) && ismember( size(calibxy,1), [3 5 9 13] )
        % set number of calibration targets
        ncalxy = size(calibxy,1);
        eval( [ 'Eyelink(''command'', ''calibration_type = HV' num2str(ncalxy) ''');' ] );

        % you must send this command with value NO for custom calibration
        % you must also reset it to YES for subsequent experiments
        Eyelink('command', 'generate_default_targets = NO');

        % modify calibration and validation target locations
        eval( [ 'Eyelink(''command'',''calibration_samples = ' num2str(ncalxy+1) ''');' ] );
        eval( [ 'Eyelink(''command'',''validation_samples = ' num2str(ncalxy) ''');' ] );
        tmpstr_cal = '0';
        tmpstr_val = '0';
        for itmp = 1:ncalxy
            tmpstr_cal = sprintf( '%s, %s', tmpstr_cal, num2str(itmp) );
            tmpstr_val = sprintf( '%s, %s', tmpstr_val, num2str(itmp) );
        end
        Eyelink('command', [ 'calibration_sequence = ' tmpstr_cal ] );
        Eyelink('command', [ 'validation_sequence = ' tmpstr_val ] );

        % set calibration target coordinates
        xyvect = reshape(calibxy', 1, numel(calibxy));
        tmpstr_cal = [ 'Eyelink(''command'',''calibration_targets = ' repmat('%d,%d ',1,ncalxy) ''''];
        tmpstr_val = [ 'Eyelink(''command'',''validation_targets = ' repmat('%d,%d ',1,ncalxy) ''''];
        for itmp = 1:length(xyvect)
            tmpstr_cal = sprintf('%s, %s', tmpstr_cal, num2str(xyvect(itmp)));
            tmpstr_val = sprintf('%s, %s', tmpstr_val, num2str(xyvect(itmp)));
        end
        tmpstr_cal = [ tmpstr_cal ');' ];
        tmpstr_val = [ tmpstr_val ');' ];
        eval(tmpstr_cal);
        eval(tmpstr_val);
    elseif exist('calibxy','var') && ischar(calibxy)
        % set default calibration type
        Eyelink('Command', ['calibration_type = ' calibxy]);
        Eyelink('Command', 'generate_default_targets = YES');
    elseif ~exist('calibxy','var') || isempty(calibxy)
        % set default calibration type
        Eyelink('Command', 'calibration_type = HV9');
        Eyelink('Command', 'generate_default_targets = YES');
    else
        error('Input for calibration coordinates is not conform allowed formats');
    end
    Eyelink('command', 'calibration_area_proportion = 0.40, 0.60'); %
    EyelinkUpdateDefaults(el);

    % open EDF file to record eye tracking data
    edfname = [num2str(SubNo) '_' num2str(PartNo) '.edf'];
    Eyelink('openfile', edfname);
    % Eyelink('StartRecording');
end


%% calibrate eyetracker before practice
if Eyetracking
    EyelinkDoTrackerSetup(el);
    Eyelink('StartRecording');
end


%% start eyelink recording
if Eyetracking
    Eyelink('Command', 'set_idle_mode'); %start recording eye position (preceded by a short pause to finish the mode transition)
    WaitSecs(0.1);
    Eyelink('StartRecording');
    WaitSecs(0.1);
end
%%%-----------------------------------------------------------------------------------------

%% Eyelink-marker
if Eyetracking
    Eyelink('Message', 'Part %d Begin', PartNo);
end
%%%-----------------------------------------------------------------------------------------------------


%% start stimuli presenting
try
    for t = 1:TrialNum
        if  t == 1

            %% instruction-image
            % Get image and write to buffer
            Screen('FillRect', scr.wptr,[0 0 0]);
            img = Screen ('MakeTexture', scr.wptr, imread(sprintf ('task_instruction_recuevalid_v1_testcolor.jpg')));
            Screen ('DrawTexture', scr.wptr, img);
            Screen( 'Flip',scr.wptr);

            KbName('UnifyKeyNames');
            key_continue = KbName('space');
            reaction = 0;
            while (reaction == 0);
                [KeyIsDown, secs, KeyCode] = KbCheck;
                if KeyCode(key_continue);
                    break;
                end;
            end
            KbWait;
            Pblank=Screen(scr.wptr,'OpenOffscreenWindow',scr.color,[],32);
            Screen('Flip',scr.wptr);
            WaitSecs(0.2);

            %% instruction-general
            Screen('TextFont',scr.wptr,'Arial')
            Screen('TextSize',scr.wptr,20);
            Screen('FillRect',scr.wptr,scr.color)
            DrawFormattedText(scr.wptr,['Get ready to start!\n\nKeep your eyes on the fixation "+".\n\nONLY blink between response and the next trial.\n\nPlease response as precise as possible!\n\nPress SPACE to begin'],'center','center',[0 0 0]);
            Screen('Flip',scr.wptr);

            KbName('UnifyKeyNames');
            key_continue = KbName('space');
            reaction = 0;
            while (reaction == 0);
                [KeyIsDown, secs, KeyCode] = KbCheck;
                if KeyCode(key_continue);
                    break;
                end;
            end
            KbWait;
            Pblank=Screen(scr.wptr,'OpenOffscreenWindow',scr.color,[],32);
            Screen('Flip',scr.wptr);
            WaitSecs(0.2);

            %% instruction-different blocks
            Screen('TextFont',scr.wptr,'Arial')
            Screen('TextSize',scr.wptr,20);
            Screen('FillRect',scr.wptr,scr.color)

            if BlkSeq_cp(PartNo) == 1
                DrawFormattedText(scr.wptr,['The cue is 100% valid.\n\nThe tested grating is 100% the cued grating!\n\nUse the cue will make the task easier!\n\nPress SPACE to begin'],'center','center',[0 0 0]);
            elseif BlkSeq_cp(PartNo) == 2
                DrawFormattedText(scr.wptr,['The cue is 80% valid.\n\nThe tested grating is 80% the cued grating!\n\nUse the cue will make the task easier!\n\nPress SPACE to begin'],'center','center',[0 0 0]);
            elseif BlkSeq_cp(PartNo) == 3
                DrawFormattedText(scr.wptr,['The cue is 60% valid.\n\nThe tested grating is 60% the cued grating!\n\nUse the cue will make the task easier!\n\nPress SPACE to begin'],'center','center',[0 0 0]);
            end
            % DrawFormattedText(scr.wptr,['Get ready to start!\n\nKeep your eyes on the fixation "+".\n\nONLY blink between response and the next trial.\n\nPlease response as precise as possible!\n\nPress SPACE to begin'],'center','center',[0 0 0]);
            Screen('Flip',scr.wptr);

            KbName('UnifyKeyNames');
            key_continue = KbName('space');
            reaction = 0;
            while (reaction == 0);
                [KeyIsDown, secs, KeyCode] = KbCheck;
                if KeyCode(key_continue);
                    break;
                end;
            end
            KbWait;
            Pblank=Screen(scr.wptr,'OpenOffscreenWindow',scr.color,[],32);
            Screen('Flip',scr.wptr);
            WaitSecs(1); % force to see at least 1sec


        elseif mod(t,break_after) == 1 && t > 1
            Screen('TextFont',scr.wptr,'Arial')
            Screen('TextSize',scr.wptr,20);
            Screen('FillRect',scr.wptr,scr.color);
            DrawFormattedText(scr.wptr,['Take a short break.\n\n' num2str(TrialNum-t+1) ' trials left in this block.\n\nYour average score so far is ' num2str((90-mean(abs(deg_matrix(1:t-1,16))))/90*100) '\n\nPlease response as precise as possible!\n\nKeep your eyes on the fixation "+".\n\nONLY blink between response and the next trial.\n\nPress SPACE to continue the experient.'],'center','center',[0 0 0]);
            Screen('Flip',scr.wptr);

            % save temporary data
            save (fullfile (['temp_Practice_recuevalid_v1_sub' num2str(SubNo)  '_part' num2str(PartNo) '_miniblock' num2str((t-1)/break_after)]));

            KbName('UnifyKeyNames');
            key_continue = KbName('space');
            reaction = 0;
            while (reaction == 0)
                [KeyIsDown, secs, KeyCode] = KbCheck;
                if KeyCode(key_continue)
                    break;
                end
            end
            KbWait;
            Pblank=Screen(scr.wptr,'OpenOffscreenWindow',scr.color,[],32);
            Screen('Flip',scr.wptr);

            %% instruction-different blocks
            Screen('TextFont',scr.wptr,'Arial')
            Screen('TextSize',scr.wptr,20);
            Screen('FillRect',scr.wptr,scr.color)

            if BlkSeq_cp(PartNo) == 1
                DrawFormattedText(scr.wptr,['The cue is 100% valid.\n\nThe tested grating is 100% the cued grating!\n\nUse the cue will make the task easier!\n\nPress SPACE to begin'],'center','center',[0 0 0]);
            elseif BlkSeq_cp(PartNo) == 2
                DrawFormattedText(scr.wptr,['The cue is 80% valid.\n\nThe tested grating is 80% the cued grating!\n\nUse the cue will make the task easier!\n\nPress SPACE to begin'],'center','center',[0 0 0]);
            elseif BlkSeq_cp(PartNo) == 3
                DrawFormattedText(scr.wptr,['The cue is 60% valid.\n\nThe tested grating is 60% the cued grating!\n\nUse the cue will make the task easier!\n\nPress SPACE to begin'],'center','center',[0 0 0]);
            end
            Screen('Flip',scr.wptr);

            KbName('UnifyKeyNames');
            key_continue = KbName('space');
            reaction = 0;
            while (reaction == 0);
                [KeyIsDown, secs, KeyCode] = KbCheck;
                if KeyCode(key_continue);
                    break;
                end;
            end
            KbWait;
            Pblank=Screen(scr.wptr,'OpenOffscreenWindow',scr.color,[],32);
            Screen('Flip',scr.wptr);
            WaitSecs(1); % force to see at least 1sec

        end

        %% Eyelink-marker
        if Eyetracking
            Eyelink('Message', 'TrialNo %d', t);
            PCStartInt = round(GetSecs*1000);
            Eyelink('Message', 'TrialStartTime %d', PCStartInt);
        end
        %%%-----------------------------------------------------------------------------------------------------


        %% Fixation
        Screen('FillRect',scr.wptr,scr.color);
        Screen('TextSize',scr.wptr,param.lenfix);
        DrawFormattedText(scr.wptr,('+'),'center','center',[0 0 0],[],[],[],[]);
        Screen('Flip',scr.wptr);
        
        %%%-----------------------------------------------------------------------------------------------------
        if Eyetracking
            Eyelink('Message', 'trig10'); % fixation onset-10
        end
        %%%-----------------------------------------------------------------------------------------------------
        % Send EEG Trigger
        %%%-----------------------------------------------------------------------------------------------------
        if EEGrecording
            fwrite(SerialPortObj, fixEEGTrig,'sync');%send trigger
            pause(0.005);
            fwrite(SerialPortObj, 0,'sync');%send a code to clean the port register
            pause(0.005);
        end
        %%%-----------------------------------------------------------------------------------------------------

        WaitSecs(param.timeFix);


        %% Sample Display
        % draw fixation
        Screen('FillRect',scr.wptr,scr.color);
        Screen('TextSize',scr.wptr,param.lenfix);
        DrawFormattedText(scr.wptr,('+'),'center','center',[0 0 0],[],[],[],[]);

        recuevalid_v1_ColorGratingSam(deg_matrix(t,3),deg_matrix(t,4),deg_matrix(t,5),deg_matrix(t,6),param,scr); % Input values: tardeg(:,1)-left; tardeg(:,2)-right; tarcol(:,1)-left; tarcol(:,2)-right
 
        %%%-----------------------------------------------------------------------------------------------------
        if Eyetracking
            Eyelink('Message', 'trig20'); % sample onset-20
        end
        %%%-----------------------------------------------------------------------------------------------------
        % Send EEG Trigger
        %%%-----------------------------------------------------------------------------------------------------
        if EEGrecording
            fwrite(SerialPortObj, samEEGTrig,'sync');%send trigger
            pause(0.005);
            fwrite(SerialPortObj, 0,'sync');%send a code to clean the port register
            pause(0.005);
        end
        %%%-----------------------------------------------------------------------------------------------------

        WaitSecs(param.timeSam);


        %% Delay1
        Screen('FillRect',scr.wptr,scr.color);
        Screen('TextSize',scr.wptr,param.lenfix);
        DrawFormattedText(scr.wptr,('+'),'center','center',[0 0 0],[],[],[],[]);
        Screen('Flip',scr.wptr);
        
        %%%-----------------------------------------------------------------------------------------------------
        if Eyetracking
            Eyelink('Message', 'trig30'); % sample delay onset-30
        end
        %%%-----------------------------------------------------------------------------------------------------
        % Send EEG Trigger
        %%%-----------------------------------------------------------------------------------------------------
        if EEGrecording
            fwrite(SerialPortObj, delay1EEGTrig,'sync');%send trigger
            pause(0.005);
            fwrite(SerialPortObj, 0,'sync');%send a code to clean the port register
            pause(0.005);
        end
        %%%-----------------------------------------------------------------------------------------------------

        WaitSecs(param.timeDelay1);


        %% Retro-cue
        Screen('FillRect',scr.wptr,scr.color);
        Screen('TextSize',scr.wptr,param.lenfix);
        if deg_matrix(t,9) == 1
            DrawFormattedText(scr.wptr,('+'),'center','center',param.tar_co1,[],[],[],[]); % orange
        elseif deg_matrix(t,9) == 2
            DrawFormattedText(scr.wptr,('+'),'center','center',param.tar_co2,[],[],[],[]); % blue
        elseif deg_matrix(t,9) == 3
            DrawFormattedText(scr.wptr,('+'),'center','center',[0 0 0],[],[],[],[]); % black
        end
        Screen('Flip',scr.wptr);

        % send cueside triggers--with cue-onset
        %%%-----------------------------------------------------------------------------------------------------
        cueside = deg_matrix(t,8); % cueside_1left2right
        if Eyetracking
            Eyelink('Message', 'trig40');
            Eyelink('Message', 'trig4%d', cueside); 
        end
        %%%-----------------------------------------------------------------------------------------------------
        % Send EEG Trigger
        %%%-----------------------------------------------------------------------------------------------------
        if EEGrecording
            fwrite(SerialPortObj, cuesideEEGTrig(cueside),'sync');%send trigger
            pause(0.005);
            fwrite(SerialPortObj, 0,'sync');%send a code to clean the port register
            pause(0.005);
        end
        %%%-----------------------------------------------------------------------------------------------------

        WaitSecs(param.timeRecue); % retrocue-200ms


        %% Delay2
        Screen('FillRect',scr.wptr,scr.color);
        Screen('TextSize',scr.wptr,param.lenfix);
        DrawFormattedText(scr.wptr,('+'),'center','center',[0 0 0],[],[],[],[]);
        Screen('Flip',scr.wptr);

         % send cuetype triggers--after cue-offset
        %%%-----------------------------------------------------------------------------------------------------
        cuetype = deg_matrix(t,7); % cuetype: 1retroValid2retroInvalid3neutral
        if Eyetracking
            Eyelink('Message', 'trig50'); % delay2 onset
            Eyelink('Message', 'trig5%d', cuetype); 
        end
        %%%-----------------------------------------------------------------------------------------------------
        % Send EEG Trigger
        %%%-----------------------------------------------------------------------------------------------------
        if EEGrecording
            fwrite(SerialPortObj, cuetypeEEGTrig(cuetype),'sync');%send trigger
            pause(0.005);
            fwrite(SerialPortObj, 0,'sync');%send a code to clean the port register
            pause(0.005);
        end
        %%%-----------------------------------------------------------------------------------------------------

        WaitSecs(param.timeDelay2);


        %% Test phase
 
        %%%-----------------------------------------------------------------------------------------------------
        if Eyetracking
            Eyelink('Message', 'trig60'); % test onset-60
        end
        %%%-----------------------------------------------------------------------------------------------------
        % Send EEG Trigger
        %%%-----------------------------------------------------------------------------------------------------
        if EEGrecording
            fwrite(SerialPortObj, testonEEGTrig,'sync');%send trigger
            pause(0.005);
            fwrite(SerialPortObj, 0,'sync');%send a code to clean the port register
            pause(0.005);
        end
        %%%-----------------------------------------------------------------------------------------------------

        % !! There is no fixation during test stage !!
        IniTestDeg=randsample(1:180,1);
        [respDeg,respRT,respStartRT]=recuevalid_v1_ColorGratingTest_respStart(IniTestDeg,deg_matrix(t,11),param,scr,Eyetracking,EEGrecording,SerialPortObj); % input values: teststartdeg, test_color
        HideCursor;

        %%%-----------------------------------------------------------------------------------------------------
        if Eyetracking
            Eyelink('Message', 'trig70'); % response-70
        end
        %%%-----------------------------------------------------------------------------------------------------
        % Send EEG Trigger
        %%%-----------------------------------------------------------------------------------------------------
        if EEGrecording
            fwrite(SerialPortObj, respEEGTrig,'sync');%send trigger
            pause(0.005);
            fwrite(SerialPortObj, 0,'sync');%send a code to clean the port register
            pause(0.005);
        end
        %%%-----------------------------------------------------------------------------------------------------


        %% extract useful results
        deg_matrix(t,12) = IniTestDeg;
        deg_matrix(t,13) = respDeg;
        deg_matrix(t,14) = respRT;
        resp_diff = respDeg-deg_matrix(t,10); % response difference (resp_deg-cuedtar_deg)
        deg_matrix(t,15) = resp_diff; % response difference

        % rearrange the response difference into -90~90 space
        if resp_diff >- 90 && resp_diff < 90
            resp_error = resp_diff;
        end
        if resp_diff < -90 || resp_diff == -90
            resp_error = resp_diff+180;
        end
        if resp_diff > 90 || resp_diff == 90
            resp_error = resp_diff-180;
        end
        clear resp_diff
        deg_matrix(t,16) = resp_error; % response error in -90~90 degree


        %% Feedback--percentage
        Screen('FillRect',scr.wptr,scr.color);
        Screen('TextSize',scr.wptr,param.lenfix);
        DrawFormattedText(scr.wptr,('+'),'center','center',[0 0 0],[],[],[],[]);
        AnswerMessage =num2str(round(100*((90-abs(resp_error))/90))); % change response error into 100, 0 error-100, 90 error-0
        DrawFormattedText(scr.wptr,(AnswerMessage),'center',[scr.yc-10],[0 0 0],[],[],[],[]);
        Screen('Flip',scr.wptr);
        WaitSecs(0.2);

        deg_matrix(t,17) = 100*((90-abs(resp_error))/90); % feedback score


        %% Escape the experiment when necessary
        KbName('UnifyKeyNames');
        key_quit = KbName('escape');
        [KeyIsDown, secs, KeyCode] = KbCheck;
        if KeyCode(key_quit)
            ListenChar;
            Screen('CloseAll'); % immediately stop program if abort-key is pressed
            break
        end


        %% ITI
        % Fixation always on
        Screen('FillRect',scr.wptr,scr.color);
        Screen('TextSize',scr.wptr,param.lenfix);
        DrawFormattedText(scr.wptr,('+'),'center','center',[0 0 0],[],[],[],[]);
        Screen('Flip',scr.wptr);
     
        %%%-----------------------------------------------------------------------------------------------------
        if Eyetracking
            Eyelink('Message', 'trig80'); % iti-80
        end
        %%%-----------------------------------------------------------------------------------------------------
        % Send EEG Trigger
        %%%-----------------------------------------------------------------------------------------------------
        if EEGrecording
            fwrite(SerialPortObj, itiEEGTrig,'sync');%send trigger
            pause(0.005);
            fwrite(SerialPortObj, 0,'sync');%send a code to clean the port register
            pause(0.005);
        end
        %%%-----------------------------------------------------------------------------------------------------

        rand_ITI = randsample(800:50:1000,1)/1000; % for blinkings
        WaitSecs(rand_ITI);

        deg_matrix(t,18) = rand_ITI;
        clear rand_ITI resp_error

        % add response start RT
        deg_matrix(t,19) = respStartRT;


        %%%-------------------------------------------------------------------------------------------
        if Eyetracking
            Eyelink('Message', 'Trial %d end', t);
        end
        %%%-------------------------------------------------------------------------------------------

    end


    %% Add new paramter labels
        deg_matrix_newlabel = {'12-InitialTestDeg'; '13-respDeg'; '14-RT'; '15-respDiff'; '16-respError'; '17-FeedbackScore'; '18-ITI';'19-respStartRT';};
        deg_matrix_label = [deg_matrix_label; deg_matrix_newlabel];
        clear deg_matrix_newlabel    


    %% Eyelink-marker
    if Eyetracking
        Eyelink('Message', 'Part %d End', PartNo);
    end
    %%%-----------------------------------------------------------------------------------------------------


    %% record the EDF data to PC
    if Eyetracking
        Eyelink('Message', 'ENDTEST');
        Eyelink('Command', 'set_idle_mode');
        WaitSecs(0.5);
        Eyelink('StopRecording');
        WaitSecs(0.5);
        Eyelink('CloseFile');
        WaitSecs(0.5);
        status = Eyelink('ReceiveFile',edfname);
        if status > 0
            fprintf('ReceiveFile status %d\n', status);
        end
        % Eyelink('Shutdown');
        movefile([pwd filesep edfname], ['Practice_recuevalid_v1_condi_' num2str(BlkSeq_cp(PartNo)) '_sub' edfname]); % move file to EDF
    end

    
    %% Close Serial Port
    fclose(SerialPortObj);


    %% Finish the experiment
    DrawFormattedText(scr.wptr, ['Practice Finished!\n\nYour final average score is ' num2str(round((90-mean(abs(deg_matrix(1:TrialNum,16))))/90*100)) '\n\nPlease call the experimenter.'], 'center', 'center', [0 0 0]);
    Screen('Flip', scr.wptr);
    KbStrokeWait;
    Screen('CloseAll');


    %% Save data
    save (fullfile (['Practice_recuevalid_v1_sub' num2str(SubNo)  '_part' num2str(PartNo) '_condi' num2str(BlkSeq_cp(PartNo))]));
    Screen('CloseAll');

    mean_resp_error = mean(abs(deg_matrix(1:TrialNum,16)));
    disp(['Mean_response_error: ',num2str(mean_resp_error)]);


catch
    ListenChar(0);
    ShowCursor;
    psychrethrow(psychlasterror);
    Screen('CloseAll');
end





