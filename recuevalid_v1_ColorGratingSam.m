function recuevalid_v1_ColorGratingSam(tar_deg_left,tar_deg_right,tar_col_left,tar_col_right,param,scr)
% draw sinewaveGratings as targets

% set grating parameters
gra_width = param.lencir_radius*2;
gra_height = param.lencir_radius*2;
if tar_deg_left == 0
    angle_l = 180;
else
    angle_l = tar_deg_left;
end
if tar_deg_right == 0
    angle_r = 180;
else
    angle_r = tar_deg_right;
end

% contrast = 0.8;
contrast = 1;
% phase = 0;
phase = 90;
% numCycles = 0.65;
% freq = numCycles/(param.deggabor*2); % Spatial Frequency (Cycles Per Degree)
numCycles = 7;
freq = numCycles/gra_width; % Spatial Frequency (Cycles Per Pixel)
% One Cycle = Grey-Black-Grey-White-Grey i.e. One Black and One White Lobe

% set rect coordinates for gratings
positionscale_l = [scr.xc-param.lendistance-param.lencir_radius; scr.yc-param.lencir_radius; scr.xc-param.lendistance+param.lencir_radius; scr.yc+param.lencir_radius;];%left
positionscale_r = [scr.xc+param.lendistance-param.lencir_radius; scr.yc-param.lencir_radius; scr.xc+param.lendistance+param.lencir_radius; scr.yc+param.lencir_radius;];%right

% generate gratings
% all the inputs for CreateProceduralSineGrating.function should be integer!!!
% [gratingid, ~] = CreateProceduralSineGrating(scr.wptr, round(gra_width), round(gra_height), [1 1 1 0],round(param.lencir_radius) ,1);
% [gratingid, ~,~] = CreateProceduralColorGrating(scr.wptr, round(gra_width), round(gra_height), [1 1 1 0],round(param.lencir_radius) ,1);
% 1-red, 2-green in this case:  [1 0 0 0], [0 1 0 0]
if tar_col_left == 1 
    [gratingid1, ~,~] = CreateProceduralColorGrating(scr.wptr, round(gra_width), round(gra_height), [param.tar_co1/255 0],[scr.color/255] ,round(gra_width)/2); % stim_color1, background_color
    [gratingid2, ~,~] = CreateProceduralColorGrating(scr.wptr, round(gra_width), round(gra_height), [param.tar_co2/255 0],[scr.color/255] ,round(gra_width)/2); % stim_color2, background_color

    Screen('FillRect',scr.wptr,scr.color);
    % present left & right gratings with different colors
    Screen('DrawTexture', scr.wptr, gratingid1, [], positionscale_l, angle_l, [], [], [], [], [], [phase+180, freq, contrast, 0]);
    Screen('DrawTexture', scr.wptr, gratingid2, [], positionscale_r, angle_r, [], [], [], [], [], [phase+180, freq, contrast, 0]);

elseif tar_col_left == 2
    [gratingid1, ~,~] = CreateProceduralColorGrating(scr.wptr, round(gra_width), round(gra_height), [param.tar_co2/255 0],[scr.color/255] ,round(gra_width)/2); % stim_color1, background_color
    [gratingid2, ~,~] = CreateProceduralColorGrating(scr.wptr, round(gra_width), round(gra_height), [param.tar_co1/255 0],[scr.color/255] ,round(gra_width)/2); % stim_color2, background_color
    
    Screen('FillRect',scr.wptr,scr.color);
    % present left & right gratings with different colors
    Screen('DrawTexture', scr.wptr, gratingid1, [], positionscale_l, angle_l, [], [], [], [], [], [phase+180, freq, contrast, 0]);
    Screen('DrawTexture', scr.wptr, gratingid2, [], positionscale_r, angle_r, [], [], [], [], [], [phase+180, freq, contrast, 0]);
end

Screen('TextSize',scr.wptr,param.lenfix);
DrawFormattedText(scr.wptr,('+'),'center','center',[0 0 0],[],[],[],[]);
Screen('Flip',scr.wptr);

end
