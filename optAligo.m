% Create an Optickle model of Advanced LIGO

function opt = optAligo(par)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Add a Field Source

% create an empty model, with frequencies specified
opt = Optickle(par.Laser.vFrf);

% add a source, with RF amplitudes specified
opt = addSource(opt, 'Laser', par.Laser.vArf);

% add modulators for Laser amplitude and phase noise
opt = addModulator(opt, 'AM', 1);
opt = addModulator(opt, 'PM', 1i);

% link, output of Laser is PM->out
opt = addLink(opt, 'Laser', 'out', 'AM', 'in', 0);
opt = addLink(opt, 'AM', 'out', 'PM', 'in', 0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Add Input Optics
% The argument list for addMirror is:
% [opt, sn] = addMirror(opt, name, aio, Chr, Thr, Lhr, Rar, Lmd)
% type "help addMirror" for more information


% Modulators
opt = addRFmodulator(opt, 'Mod1', par.Mod.f1, 1i * par.Mod.g1);
opt = addRFmodulator(opt, 'Mod2', par.Mod.f2, 1i * par.Mod.g2);

% link, No MZ
opt = addLink(opt, 'PM', 'out', 'Mod1', 'in', 5);
opt = addLink(opt, 'Mod1', 'out', 'Mod2', 'in',5);% 0.05);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Add Core Optics
%
% The parameter struct must contain parameters the following
% for each mirror: T, L, Rar, mechTF, pos, ROC

listMirror = {'PR', 'BS', 'IX', 'IY', 'EX', 'EY', 'SR'};

for n = 1:length(listMirror)
  name = listMirror{n};
  p = par.(name);

  % add mirror
  if strmatch(name, 'BS')
    opt = addBeamSplitter(opt, name, 45, 1 / p.ROC, p.T, p.L, p.Rar, 10e-6);
  else
    opt = addMirror(opt, name, 0, 1 / p.ROC, p.T, p.L, p.Rar, 10e-6);
  end

  % set mechanical transfer-functions and mirror position offsets
  opt = setPosOffset(opt, name, p.pos);
end

dampRes = [0.01 + 1i, 0.01 - 1i];
opt = setMechTF(opt, 'IX', zpk([], -par.w * dampRes, 1 / par.mass));
opt = setMechTF(opt, 'EX', zpk([], -par.w * dampRes, 1 / par.mass));
opt = setMechTF(opt, 'IY', zpk([], -par.w * dampRes, 1 / par.mass));
opt = setMechTF(opt, 'EY', zpk([], -par.w * dampRes, 1 / par.mass));
opt = setMechTF(opt, 'PR', zpk([], -par.w * dampRes, 1 / par.mass));
opt = setMechTF(opt, 'BS', zpk([], -par.w * dampRes, 1 / par.mass));
opt = setMechTF(opt, 'SR', zpk([], -par.w * dampRes, 1 / par.mass));

opt = setMechTF(opt, 'IX', zpk([], -par.w_pit * dampRes, 1 / par.iI), 2);
opt = setMechTF(opt, 'EX', zpk([], -par.w_pit * dampRes, 1 / par.iI), 2);
opt = setMechTF(opt, 'IY', zpk([], -par.w_pit * dampRes, 1 / par.iI), 2);
opt = setMechTF(opt, 'EY', zpk([], -par.w_pit * dampRes, 1 / par.iI), 2);
opt = setMechTF(opt, 'PR', zpk([], -par.w_pit * dampRes, 1 / par.iI), 2);
opt = setMechTF(opt, 'BS', zpk([], -par.w_pit * dampRes, 1 / par.iI), 2);
opt = setMechTF(opt, 'SR', zpk([], -par.w_pit * dampRes, 1 / par.iI), 2);

% link Modulators output to PR (no input Mode Cleaner)
opt = addLink(opt, 'Mod2', 'out', 'PR', 'bk', 0.2);%35);

% link BS A-side inputs to PR front output
opt = addLink(opt, 'PR', 'fr', 'BS', 'frA', par.Length.PR);


% link BS A-side outputs to and IX and IY back inputs
opt = addLink(opt, 'BS', 'frA', 'IY', 'bk', par.Length.IY);
opt = addLink(opt, 'BS', 'bkA', 'IX', 'bk', par.Length.IX);

% link BS B-side inputs to and IX and IY back outputs
opt = addLink(opt, 'IY', 'bk', 'BS', 'frB', par.Length.IY);
opt = addLink(opt, 'IX', 'bk', 'BS', 'bkB', par.Length.IX);

% link BS B-side outputs to PR front inputs
opt = addLink(opt, 'BS', 'frB', 'PR', 'fr', par.Length.PR);

% link the arms
opt = addLink(opt, 'IX', 'fr', 'EX', 'fr', par.Length.EX);
opt = addLink(opt, 'EX', 'fr', 'IX', 'fr', par.Length.EX);

opt = addLink(opt, 'IY', 'fr', 'EY', 'fr', par.Length.EY);
opt = addLink(opt, 'EY', 'fr', 'IY', 'fr', par.Length.EY);

% link BS to signal recycling mirror
opt = addLink(opt, 'BS', 'bkB', 'SR', 'fr', 2.5);
opt = addLink(opt, 'SR', 'fr', 'BS', 'bkA', 2.5);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define AS port (before the OMC)

% Add BS with R = 0.99 ==> 99% of the power goes to the OMC,
% 1% of the power is detected at the AS port (before the OMC)

opt = addMirror(opt, 'ASsplit', 45, 0, 0.03, 0, 0, 0);
opt = addLink(opt, 'SR', 'bk', 'ASsplit', 'fr', 2.5);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Add OMC mirrors

% Add lens before the OMC mirror
% Mode matching: I want to match the basis before the telescope with the basis
% afterwards (basis defined as q = z + z_0*i, with z distance past the waist and
% z_0 Rayleigh range (Help on getLinkLengths, OpHG)


fL = 33.1;
opt = addTelescope(opt, 'OMCtel1', fL);

% using realistic values, from T080144

OMC_perimeter = 1.077;
opt = addMirror(opt, 'OMCa', 0, 1/1.96, 8300e-6, 30e-6);
opt = addMirror(opt, 'OMCb', 0, 1/1.96, 8300e-6, 30e-6);
opt = addLink(opt, 'OMCa', 'fr', 'OMCb', 'fr', OMC_perimeter/2);
opt = addLink(opt, 'OMCb', 'fr', 'OMCa', 'fr', OMC_perimeter/2);

opt = addLink(opt, 'ASsplit', 'fr', 'OMCtel1', 'in', 2.5);
opt = addLink(opt, 'OMCtel1', 'out', 'OMCa', 'bk', (fL - 0.036));


% tell Optickle to use this cavity basis
opt = setCavityBasis(opt, 'IX', 'EX');
opt = setCavityBasis(opt, 'IY', 'EY');
opt = setCavityBasis(opt, 'OMCa', 'OMCb');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



