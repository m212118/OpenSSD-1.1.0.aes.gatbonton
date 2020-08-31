load('000F-SMALL0017_12_20188_48_28 AM.mat')
wall=Recorder1.Channels.Segments.Data.Samples;,ssd=Recorder2.Channels.Segments.Data.Samples;

Ts=Recorder1.Channels.Segments.Data.dXstep;
t=(0:length(ssd)-1)*Ts;

figure(2),plot(t,ssd),title('ssd')


lev = 5;
wname = 'sym8';

% wall=wall(1:50000);
% t=t(1:length(wall));

[dnsig1,c1,l1,threshold_SURE] = wden(wall,'rigrsure','h','mln',lev,wname);
[dnsig2,c2,l2,threshold_Minimax] = wden(wall,'minimaxi','h','mln',lev,wname);
[dnsig3,c3,l3,threshold_DJ] = wden(wall,'sqtwolog','h','mln',lev,wname);


figure(1)
subplot(4,1,1)
plot(t,wall)
title('noisy wall data')
subplot(4,1,2)
plot(t,dnsig1)
title('Denoised Signal - SURE')
subplot(4,1,3)
plot(t,dnsig2)
title('Denoised Signal - Minimax')
subplot(4,1,4)
plot(t,dnsig3)
title('Denoised Signal - Donoho-Johnstone')

m1=100;
m2=3333;
ma1=filter(ones(1,m1)*1/m1,1,wall);
ma2=filter(ones(1,m2)*1/m2,1,wall);
figure(2),subplot(4,1,1),plot(t,wall),title('noisy wall data')
subplot(4,1,2),plot(t,ma1),title('moving average filter length 100')
subplot(4,1,3),plot(t,ma2),title('moving average filter length m2')
subplot(4,1,4),plot(t,wall-ma2),title('wall - moving average length m2')


figure(4)
subplot(3,1,1),plot(t,ssd)
subplot(3,1,2),plot(t,filter(ones(1,m2)*1/m2,1,ssd)),title('moving average filter length m2')
subplot(3,1,3),plot(t,ma2),title('moving average filter length m2 on wall')


