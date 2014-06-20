% SISO LS-EC
M = 16; % QAM order
N = 1000000;
SIRdB=20;
SNRdB=40;%Error Vector Magnitude
%near end signal
tx_near_code = randint(N,1,M);
tx_near=modulate(modem.qammod(M),tx_near_code);
tx_near_noise=awgn(tx_near,SNRdB,'measured');


%far end signal
tx_far_code = randint(N,1,M);
tx_far=modulate(modem.qammod(M),tx_far_code)/10^(SIRdB/20);%far signal weaker
tx_far_noise=awgn(tx_far,SNRdB,'measured');%add noise
tx_signal=tx_near_noise+tx_far_noise;

%12bit A/D
tmp=tx_signal(:);
tmp=round(tmp*2048)/2048;
tx_signal=tmp(:);



%LS channel estimation
H_est=inv(tx_near'*tx_near)*tx_near'*tx_signal;
%near end signal estimation
tx_est=tx_near*H_est;
%substract to get far signal
tx_ec=tx_signal-tx_est;

%plot the constellation of received signal
%scatterplot(tx_signal);
%scatterplot(tx_ec);

% demodulate
z=demodulate(modem.qamdemod(M),tx_ec*10^(SIRdB/20));

% err rate
[Num_err_symbol,sym_err_rate]= symerr(tx_far_code,z)
[Num_err_bit,bit_err_rate]= biterr(tx_far_code,z)