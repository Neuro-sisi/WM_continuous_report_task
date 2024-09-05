function [param] = recuevalid_v1_getStimParams(scrreso,scrwid,scrdis)
param.timeFix = 0.500;
param.timeSam = 0.200;
param.timeDelay1 = 0.8;
param.timeRecue = 0.2;
param.timeDelay2 = 1.3;


% param.degfix = 0.63;
param.degfix = 0.75;
% param.deggabor = 3;   % gabor underling circle
% param.degdistance=6; % the distance between gabor center to screen center
param.deggabor = 2.3;   % gabor underling circle (radius of the gabor--the 8 locations are not overlapped with 2.3 maximum)
% param.deggabor = 2;   % gabor underling circle (radius of the gabor--the 8 locations are not overlapped with 2.3 maximum)
param.degdistance=6; % the distance between gabor center to screen center


pix_per_cm = scrreso/scrwid; % 1920/43
param.lenfix = round(2*scrdis*tand(param.degfix/2)*pix_per_cm);
param.lencir_radius = floor(2*scrdis*tand(param.deggabor/2)*pix_per_cm);
param.lendistance = floor(2*scrdis*tand(param.degdistance/2)*pix_per_cm);

% set parameters to draw gratings
% parameters from Eelke to make the grating has the longest bar in the center
% param.gPhase = 170;  % phase
% param.gFreq = 0.06;  % frequency
% param.gCont = 1;  % contrast
% param.gSig = 0;  % sigma

% set target color
param.tar_co1 = [21 165 234];
param.tar_co2 = [234 74 21];


end
