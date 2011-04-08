
% Set up the model
par = paramAdvH1;
opt = optAligo(par);

% Add some probes
opt = addSink(opt, 'OMCT');
opt = addLink(opt, 'OMCb', 'bk', 'OMCT', 'in', 0.1);
opt = addProbeIn(opt, 'OMCT DC', 'OMCT', 'in',  0,  0);

nOMCprobe = getProbeNum(opt, 'OMCT DC');
nEXdrive = getDriveNum(opt, 'EX');
nEYdrive = getDriveNum(opt, 'EY');
nSRdrive = getDriveNum(opt, 'SR');

% Put in a DARM offset
dLm = 3e-12;                   
pos = zeros(opt.Ndrive, 1);
pos(nEXdrive) =  dLm / 2;
pos(nEYdrive) = -dLm / 2;

% put in a SRC offset
pos(nSRdrive) = 0;

% Tickle
f = logspace(log10(1.0), log10(10e3), 301);
[fDC, sigDC, sigAC, mMech, noiseAC] = tickle(opt, pos, f);

%% Get the DC readout optical gain

hX = getTF(sigAC, nOMCprobe, nEXdrive);
hY = getTF(sigAC, nOMCprobe, nEYdrive);
hDC = hY - hX;

loglog(f, abs(hDC));