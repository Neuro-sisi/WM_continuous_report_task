function [respDeg,respRT,respStartRT]=recuevalid_v1_ColorGratingTest(test_degree,test_color,param,scr,Eyetracking,EEGrecording,SerialPortObj)
% draw sinewaveGratings as targets

% set grating parameters
gra_width = param.lencir_radius*2;
gra_height = param.lencir_radius*2;
deg_t = test_degree;
contrast = 1;
% phase = 0;
phase = 90;
numCycles = 7;
freq = numCycles/gra_width; % Spatial Frequency (Cycles Per Pixel)
% One Cycle = Grey-Black-Grey-White-Grey i.e. One Black and One White Lobe

% set rect coordinates for gratings--in the center screen
positionscale = [scr.xc-param.lencir_radius; scr.yc-param.lencir_radius; scr.xc+param.lencir_radius; scr.yc+param.lencir_radius;];
% positionscale(:,1) = [scr.xc-param.lendistance-param.lencir_radius; scr.yc-param.lencir_radius; scr.xc-param.lendistance+param.lencir_radius; scr.yc+param.lencir_radius;];%left
% positionscale(:,2) = [scr.xc+param.lendistance-param.lencir_radius; scr.yc-param.lencir_radius; scr.xc+param.lendistance+param.lencir_radius; scr.yc+param.lencir_radius;];%right

% get original grating center coordinates
xy_cir_origin = [scr.xc; scr.yc;]; %center coordinate of gratings
% xy_cir_origin(:,1) = [scr.xc-param.lendistance; scr.yc;]; %center coordinate of gratings
% xy_cir_origin(:,2) = [scr.xc+param.lendistance; scr.yc;]; %center coordinate of gratings

% generate gratings
% all the inputs for CreateProceduralSineGrating.function should be integer!!!
% % black grating
% [gratingid, ~,~] = CreateProceduralColorGrating(scr.wptr, round(gra_width), round(gra_height), [0 0 0 0],[scr.color/255] ,round(gra_width)/2); % stim_color1, background_color
if test_color == 1
    [gratingid, ~,~] = CreateProceduralColorGrating(scr.wptr, round(gra_width), round(gra_height), [param.tar_co1/255 0],[scr.color/255] ,round(gra_width)/2);
elseif test_color == 2
    [gratingid, ~,~] = CreateProceduralColorGrating(scr.wptr, round(gra_width), round(gra_height), [param.tar_co2/255 0],[scr.color/255] ,round(gra_width)/2);
end

% plot start target grating
Screen('FillRect',scr.wptr,scr.color);
% Screen('TextSize',scr.wptr,param.lenfix);
% DrawFormattedText(scr.wptr,('+'),'center','center',[0 0 0],[],[],[],[]);
Screen('DrawTexture', scr.wptr, gratingid, [], positionscale(:,1), deg_t, [], [], [], [], [], [phase+180, freq, contrast, 0]);
% Screen('DrawTexture', scr.wptr, gratingid, [], positionscale(:,1), deg_t, [], [], [], [], [], [param.gPhase, freq, contrast, 0]);
% Screen('DrawTexture', scr.wptr, gratingid, [], positionscale(:,1), deg_t, [], [], [], [], [], [param.gPhase, param.gFreq, param.gCont, param.gSig]);

% set mouse movement
WaitSetMouse(round(positionscale(1,1)+2*param.lencir_radius),round(positionscale(2,1)+param.lencir_radius),scr.nmbr);
ShowCursor('Hand',scr.wptr);
Screen('Flip',scr.wptr);
time1 = GetSecs;

while 1
    [m,n,buttons]=GetMouse(scr.wptr);
    if m~=round(positionscale(1,1)+2*param.lencir_radius) || n~=round(positionscale(2,1)+param.lencir_radius)

    if n==round(positionscale(2,1)+param.lencir_radius)+1 ||  n==round(positionscale(2,1)+param.lencir_radius)-1
        % get response initiation RT
        time3 = GetSecs;
        respStartRT = time3 - time1;
        %%%-----------------------------------------------------------------------------------------------------
        if Eyetracking
            Eyelink('Message', 'trig71'); % response initiation-71
        end
        %%%-----------------------------------------------------------------------------------------------------
        % Send EEG Trigger
        %%%-----------------------------------------------------------------------------------------------------
        if EEGrecording
            fwrite(SerialPortObj, 71 ,'sync');%send trigger
            pause(0.005);
            fwrite(SerialPortObj, 0,'sync');%send a code to clean the port register
            pause(0.005);
        end
        %%%-----------------------------------------------------------------------------------------------------
    
        if (m-xy_cir_origin(1,1))*(n-xy_cir_origin(2,1))>=0
            deg_t_new=180-atand(abs(m-xy_cir_origin(1,1))/abs(n-xy_cir_origin(2,1)));
        elseif (m-xy_cir_origin(1,1))*(n-xy_cir_origin(2,1))<0
            deg_t_new=atand(abs(m-xy_cir_origin(1,1))/abs(n-xy_cir_origin(2,1)));
        end

        % draw new(clicked) grating
        % !!! the input of the deg_t_new here should be degree!!!
        Screen('DrawTexture', scr.wptr, gratingid, [], positionscale(:,1), deg_t_new, [], [], [], [], [], [phase+180, freq, contrast, 0]);
        % Screen('DrawTexture', scr.wptr, gratingid, [], positionscale(:,1), deg_t, [], [], [], [], [], [param.gPhase, param.gFreq, param.gCont, param.gSig]);
        Screen('Flip',scr.wptr);

        if sum(buttons)>0
            time2 = GetSecs;
            respDeg = deg_t_new; %deg_t_new is degree instead of radians
            respRT = time2 - time1;
            break;
        end
    end
end

end
