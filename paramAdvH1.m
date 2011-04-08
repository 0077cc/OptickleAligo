% par = paramAdvH1()

function par = paramAdvH1(par)

% basic constants
lambda = 1064e-9;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Detector Geometry (distances in meters)

% Lengths
lPRC  = 57.656;   % PRCL: lPRC = lPR + (lIX + lIY) / 2   
lasy  = 0.050;    % Schnupp Asy: lasy = lIX - lIY
lmean = 4.38;     % (lIX + lIY) / 2  (note this is the old iLIGO value)

par.Length.IX = lmean + lasy / 2;  % distance [m] from BS to IX
par.Length.IY = lmean - lasy / 2;  % distance [m] from BS to IY
par.Length.EX = 3994.5;            % length [m] of the X arm
par.Length.EY = 3994.5;            % length [m] of the Y arm
par.Length.PR = lPRC - lmean;      % distance from PR to BS

% Radius of Curvature [m] 

par.IX.ROC = inf;
par.IY.ROC = inf;
par.EX.ROC = inf;
par.EY.ROC = inf;
par.BS.ROC = inf;
par.PR.ROC = inf;
par.SR.ROC = inf;

% Microscopic length offsets
par.IX.pos = 0;
par.IY.pos = 0;
par.EX.pos = 0;
par.EY.pos = 0;
par.BS.pos = 0;
par.PR.pos = 0;
par.SR.pos = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Mirror Parameters

% Arm cavity Finesse and imbalance
Ltm = 0;
dLoss = 0;         % determines the contrast defect

% HR Transmissivities
par.IX.T = 0.014;
par.IY.T = 0.014;
par.BS.T = 0.5;

par.EX.T = 5e-6;
par.EY.T = 5e-6;

par.PR.T = 0.03;
par.SR.T = 0.20;

% AR Surfaces
par.IX.Rar = 100e-6;
par.IY.Rar = 100e-6;
par.EX.Rar = 100e-6;
par.EY.Rar = 100e-6;
par.BS.Rar = 100e-6;
par.PR.Rar = 100e-6;
par.SR.Rar = 100e-6;

% HR Losses
par.IX.L = Ltm;
par.IY.L = Ltm;
par.EX.L = Ltm + dLoss;
par.EY.L = Ltm - dLoss;
par.BS.L = 0;
par.PR.L = 0;
par.SR.L = 0;

% mechanical parameters
par.w = 2 * pi * 0.0;       % resonance frequency mirror (rad/s)
par.mass  = 40.0;           % mass mirror (kg)

par.w_pit = 2 * pi * 0.0;   % pitch mode resonance frequency

par.rTM = 0.340/2;          % test-mass radius
par.tTM = 0.200;            % test-mass thickness
par.iTM = (3 * par.rTM^2 + par.tTM^2) / 12;  % TM moment / mass

par.iI = par.mass * par.iTM;  % moment of mirrors
          


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input Beam Parameters
par.Pin = 120.0;  % input power (W) - P_laser*T_PMC*T_MC*T_FI
f1 = 9.099471e6;  % first modulation frequency 
f2 = 5*f1;        % second modulation frequency
Nmod1 = 1;		  % first modulation order
Nmod2 = 1;		  % second modulation order

Nmod1 = 0;
Nmod2 = 0;

% construct modulation vectors 
n1 = (-Nmod1:Nmod1)';
n2 = (-Nmod2:Nmod2)';
vFrf = unique([n1 * f1; n2 * f2; f1+f2; f1-f2; -(f1+f2); -f1+f2]);

% input amplitude is just carrier
nCarrier = find(vFrf == 0, 1);
vArf = zeros(size(vFrf));
vArf(nCarrier) = sqrt(par.Pin);

par.Laser.vFrf = vFrf;
par.Laser.vArf = vArf;
par.Laser.Power = par.Pin;
par.Laser.Wavelength = lambda;

par.Mod.f1 = f1;
par.Mod.f2 = f2;
par.Mod.g1 = 0.3; %  first modulation depth
par.Mod.g2 = 0.1; % second modulation depth

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
