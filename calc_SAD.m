%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Multichannel speaker activity detection for 16kHz audio files
%
%
% Input: files:         Cell-array containg path to each audio track
%        start_sample:  Integer value for starting frame
%        end_sample:    Integer value for end frame
%        conf:          config (content of config.m)
%
% Output: SAD           Matrix containg SAD decision for each audio channel
%                       and for each frame
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%


function SAD = calc_SAD(files, start_sample, end_sample,conf)
    
    num_sig = length(files);
    n_len = end_sample - start_sample;
    num_frames = floor((n_len-conf.frame_len)/conf.frame_shift)+1;  % # of frames

    
    % initializations
    Y_sqr   = zeros(conf.k,num_sig); % noisy speech psd
    
    % usual initialisations
    SAD = zeros(num_frames,num_sig);
    PhiHat_sigma = zeros(num_frames,num_sig);
    conf.params.ts.PhiHatYYold = zeros(conf.k,num_sig);
    conf.params.bf.XiSADsmoothedold = zeros(1,num_sig);
    conf.params.bf.EtaMaxsmoothedold = zeros(1,num_sig);
    conf.params.us.num_sig = num_sig;
    for i = 1:num_sig                              % for noise estimation
            conf.params.ne{i} = struct('CtrUpdate', 1.012, 'CtrMult', 2, ...
                                       'BetaDownExp', 1, 'BetaUpExp', 3, ...
                                       'CtrSmooth', 0.5);
            conf.params.ne{i}.ctr         = ones(conf.k,1)*realmax;
            conf.params.ne{i}.sigma2N_old = zeros(conf.k,1);
            conf.params.ne{i}.sigma2Y_old = zeros(conf.k,1);            
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % start process
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    load('HannWindow.mat');
    w_sqrt = sqrt(w);

    % ***************
    % Signal analysis
    % ***************

    % frame start index
    s_idx = 1;         
    y = zeros(conf.frame_len,num_sig);
    
    for l = 1:num_frames

        % frame end index
        e_idx = s_idx + conf.frame_len - 1;  

        % desired signal
        for ii=1:num_sig
            y(:,ii) = audioread(char(files{ii}), [s_idx+start_sample e_idx+start_sample]) * double(intmax('int16')) .* w_sqrt;
        end

        Y_full = fft(y,conf.K);
        Y = Y_full(1:conf.k,:);
        Y_sqr(:) = abs(Y).^2;    % squared magnitude of microphone signal spectra

        % Signal Power Ratio
        [SPRhatdash,PhiHat_sigma(l,:),PhiHatYY,PhiHatNN,conf.params] = sig_pow_rat(Y_sqr,conf.params,l);

        % Basis Fullband Speaker Activity Detection
        [SAD(l,:),conf.params] = improved_SAD(Y_sqr,PhiHatYY,PhiHatNN,SPRhatdash,conf.params);
                
        % next frame start index
        s_idx = s_idx + conf.frame_shift;    
    end
end

function [SPRhatdash,PhiHat_sigma,PhiHatYY,PhiHatNN,params] = sig_pow_rat(Y_sqr,params,l)

    % read parameters
    num_sig = params.us.num_sig;
    k = params.us.k;
    
    sprSmooth   = params.ts.CtrSmooth;
    PhiHatYYold = params.ts.PhiHatYYold;
    
    % predefinitions
    PhiHatNN = zeros(k,num_sig);
    PhiHat_sigma = zeros(k,num_sig);
    SPRhatdash = zeros(k,num_sig);
    
    % Temporal smoothing of squared magnitude microphone signal
    PhiHatYY = (1-sprSmooth).*PhiHatYYold + sprSmooth.*Y_sqr;
    
    for i = 1:num_sig
        % Noise power spectrum estimation
        params.ne{i}.l = l;
        [PhiHatNN(:,i), params.ne{i}] = ne_vad(Y_sqr(:,i), params.ne{i});        

        % Speech signal power spectral density (PSD)
        PhiHat_sigma(:,i) = max(PhiHatYY(:,i)-PhiHatNN(:,i),eps);
    end
    
    % Calculation Signal Power Ratio
    for i = 1:num_sig
        idx = 1:num_sig;
        idx(i) = [];
        SPRhatdash(:,i) = 10*log10(PhiHat_sigma(:,i)./max(PhiHat_sigma(:,idx),[],2));
    end
    PhiHat_sigma = sum(PhiHat_sigma);
    % Output assignments
    params.ts.PhiHatYYold = PhiHatYY;

end

function [SAD,params] = improved_SAD(Y_sqr,PhiHatYY,PhiHatNN,SPRhatdash,params)

    % read parameters
    num_sig = params.us.num_sig;
    k = params.us.k;
    gammasnr = params.bf.gamma_snr;
    phi_snr = params.bf.phi_snr;
    theta_snr = params.bf.theta_snr;
    theta_sad = params.bf.theta_sad;
    Kdash = params.bf.Kdash;
    k_ae = params.bf.k_ae;
    XiSADsmoothedold = params.bf.XiSADsmoothedold;
    
    % predefinitions
    EtaHat = zeros(k,num_sig);
    EtaHatG = zeros(Kdash,num_sig);
    SPRtilde = zeros(k,num_sig);
    SAD = zeros(1,num_sig);
    cp = zeros(k,num_sig);
    gamma_sad = ones(1,num_sig) * params.bf.gamma_sad_dec;
    
    % Modification of noise PSD
    PhiHatNNdash = gammasnr * PhiHatNN;
    
    % SNR determination
    for i = 1:num_sig
       EtaHat(:,i) = max(min(PhiHatYY(:,i),Y_sqr(:,i))-PhiHatNNdash(:,i),0)./(PhiHatNNdash(:,i)+eps);
    end
       
    % Modified quantity of the log power ratio
    SPRtilde(EtaHat>=phi_snr) = SPRhatdash(EtaHat>=phi_snr);
    
    % positive counter
    cp(SPRtilde>0) = 1;
    cplus = sum(cp);
    
    % Grouped SNR values
    for i = 1:Kdash
        EtaHatG(i,:) = 1/(k_ae(i+1)-k_ae(i))*sum(EtaHat(k_ae(i)+1:k_ae(i+1),:),1);
    end
    EtaHatGmax = max(max(EtaHatG,[],1)/10,eps);
    
    % SNR-dependent soft weighting function
    Gc = min(max(EtaHatG,[],1)/10,1);
    
    % Soft frame-based SAD measure
    XiSAD = Gc.*(cplus./k);
    
    gamma_sad(XiSAD > XiSADsmoothedold) = params.bf.gamma_sad_inc;
    XiSADsmoothed = (1-gamma_sad) .* XiSADsmoothedold + gamma_sad .* XiSAD;
    
    % Improved SAD
    SAD(XiSADsmoothed > theta_sad & EtaHatGmax > theta_snr) = 1;

    % Output Assignments
    params.bf.XiSADsmoothedold = XiSADsmoothed;
end

function [sigma2N, par_out] = ne_vad(y_fft_sqr, par_in)
    % ne_vad - Noise power spectrum estimation based on a frequency-based VAD
    % 
    % usage: [sigma2N, par_out] = ne_vad(y_fft_sqr, par_in)
    %        
    %        Noise power spectral density (psd) estimation is performed on 
    %        squared noisy speech spectral amplitudes |Y|^2 : 
    % 
    %        Input parameters:
    %        y_fft_sqr : Pre-emphasized |Y|^2
    %        par_in    : Input parameter structure:
    %           CtrUpdate  : Control parameter update factor:
    %                        The higher, the faster the VAD threshold will be 
    %                        updated in speech presence
    %           CtrMult    : Speech presence control multiplier: 
    %                        The higher, the higher the VAD threshold becomes,
    %                        the less frames will be tagged as speech presence
    %           BetaDownExp: Speech absence smoothing factor (exponent) 
    %           BetaUpExp  : Speech transition smoothing factor (exponent)
    %           CtrSmooth  : Smoothing factor for noisy speech psd estimate 
    %           sigma2Y_old: (Smoothed) noisy speech psd of the previous frame
    %           sigma2N_old: Noise psd estimate of the previous frame
    %           ctr        : Control parameter for VAD threshold of prev. frame
    %           l          : frame index
    %
    %        Output parameters:
    %	     sigma2N : Noise psd estimate
    %        par_out : Updated input parameter structure, same fields as above
    %--------------------------------------------------------------------------

    %--- Initializations ------------------------------------------------------
    %--- Read input parameters from structure
    ctrupdate   = par_in.CtrUpdate;
    ctrmult     = par_in.CtrMult;
    betadownexp = par_in.BetaDownExp;
    betaupexp   = par_in.BetaUpExp;
    ctrsmooth   = par_in.CtrSmooth;
    l           = par_in.l;

    ctr         = par_in.ctr;     
    sigma2N_old = par_in.sigma2N_old;        
    sigma2Y_old = par_in.sigma2Y_old;

    %--- Noise psd estimation -------------------------------------------------
    beta_up     = 2^(-betaupexp);
    beta_down   = 2^(-betadownexp);

    %--- Noisy speech psd estimation by recursive smoothing over time
    sigma2Y = (1-ctrsmooth).*sigma2Y_old + ctrsmooth.*y_fft_sqr;

    %--- Noise psd update in speech presence
    sigma2N             = sigma2N_old; % General copy, but partly modified:

    %--- Noise psd update in speech absence and speech transition
    idxf = find(sigma2Y <= ctrmult * ctr); % Frequency bins with no
                                           % clear speech presence
    idx1 = find(sigma2Y(idxf) < sigma2N_old(idxf)); % Frequency bins with
                                                    % clear speech absence
    sigma2N(idxf(idx1)) =      beta_down  * sigma2N_old(idxf(idx1)) ...
                          + (1-beta_down) * sigma2Y(idxf(idx1));

    idx2 = find(sigma2Y(idxf) >= sigma2N_old(idxf)); % Frequency bins of
                                                     % transitional segments
    sigma2N(idxf(idx2)) =    (1-beta_up)  * sigma2N_old(idxf(idx2)) ...
                           +    beta_up   * sigma2Y(idxf(idx2));

    %--- Control parameter update
    % Speech presence
    idxCS      = find(sigma2Y > ctrmult * ctr);
    ctr(idxCS) = ctr(idxCS) * ctrupdate;

    % Very low level signals (definitely noise only)
    idxCN      = find(sigma2Y < ctr);
    ctr(idxCN) = sigma2Y(idxCN);

    % Else
    % Keep old control parameter; do nothing.

    % Special handling of first frames to improve control parameter init
    if l < 5, 
        ctr = max(ctr,y_fft_sqr); 
    end;

    par_out.SA = sigma2Y > ctrmult * ctr; % speech activity
    par_out.ST = (sigma2Y >= sigma2N_old) & (sigma2Y <= ctrmult * ctr); % speech transition
    par_out.SP = (sigma2Y < sigma2N_old) & (sigma2Y <= ctrmult * ctr); % speech pause

    %--- Output assignments
    par_out.sigma2Y_old = sigma2Y;
    par_out.sigma2N_old = sigma2N;
    par_out.ctr = ctr;

    par_out.CtrUpdate   = ctrupdate;
    par_out.CtrMult     = ctrmult;
    par_out.BetaDownExp = betadownexp;
    par_out.BetaUpExp   = betaupexp;
    par_out.CtrSmooth   = ctrsmooth;
    par_out.l           = l;
end