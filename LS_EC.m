% SISO的LS回波消除
M = 16; % QAM调制阶数
N = 1000000;% 符号个数
SIRdB=30;%信扰比
SNRdB=45;%信噪比
%近端信号
tx_near_code = randint(N,1,M);
tx_near=modulate(modem.qammod(M),tx_near_code);
tx_near_noise=awgn(tx_near,SNRdB,'measured');


%远端信号
tx_far_code = randint(N,1,M);
tx_far=modulate(modem.qammod(M),tx_far_code)/10^(SIRdB/20);%近端信号比远端信号强
tx_far_noise=awgn(tx_far,SNRdB,'measured');%近端信号比远端信号强
tx_signal=tx_near_noise+tx_far_noise;

%引入量化误差12bit
tmp=tx_signal(:);
tmp=round(tmp*2048)/2048;
tx_signal=tmp(:);



%LS信道估计
H_est=inv(tx_near'*tx_near)*tx_near'*tx_signal;
%近端信号估计
tx_est=tx_near*H_est;
%从接收信号中减去近端信号
tx_ec=tx_signal-tx_est;

%绘制接收到的QAM星座
%scatterplot(tx_signal);
%scatterplot(tx_ec);
% 解调
z=demodulate(modem.qamdemod(M),tx_ec*10^(SIRdB/20));

% 误码率和误符号率
[Num_err_symbol,sym_err_rate]= symerr(tx_far_code,z)
[Num_err_bit,bit_err_rate]= biterr(tx_far_code,z)