%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Configuration file for the multichannel speaker activity detection
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
% Common parameter
conf.fs = 16000;        % Sampling frequency     
conf.frame_len = 512;        % frame-length
conf.frame_shift = 128;      % frame-shift
conf.K = 2^ceil(log2(conf.frame_len));  % # of FFT point
conf.k = 1 + conf.K/2; % number of frequency bins
conf.params.us = struct('num_sig',[],'k',conf.k);

% for temporal smoothing of mic PSD
sprSmooth  = 0.5;   
conf.params.ts = struct('PhiHatYYold', [], 'CtrSmooth', sprSmooth); 

gamma_snr = 4;      % factor for noise power overestimation
phi_snr = .5;       % SNR threshold for relevant bins
theta_snr = 30;     % SNR threshold for final decision
theta_sad = 0.4;    % SAD threshold for final decision

% For grouping frequency bins
Kdash = 10;
k_ae = [4,28:25:257];
    
% Smoothing paramter
gamma_sad_inc = 2.5;   
gamma_sad_dec = 0.005;

conf.params.bf = struct('phi_snr', phi_snr, 'theta_snr', theta_snr, ...
            'theta_sad', theta_sad, 'gamma_snr', gamma_snr, ...
            'Kdash', Kdash, 'k_ae', k_ae, 'gamma_sad_inc', gamma_sad_inc,...
            'gamma_sad_dec', gamma_sad_dec, 'XiSADsmoothedold', ...
            [], 'EtaMaxsmoothedold', []);
