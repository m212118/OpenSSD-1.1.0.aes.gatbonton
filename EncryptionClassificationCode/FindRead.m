function [startindex,stopindex]=FindRead(y)
% This function finds the beginning and ending index of an SSD read, and
% returns those indices.


w=y.*y;
%w=w(100000:end);    % trim off first part of file
filterlength=1000;
w=filter(ones(1,filterlength)*1/filterlength,1,w);
th=max(w)*.75;
v=find(w>th);
startindex=v(1);
stopindex=v(end);
%mask=logical(zeros(size(w)));
% mask(startindex:stopindex)=1;
%  figure(2), subplot(2,1,1),plot(w)
%  subplot(2,1,2),plot(mask),axis([1 length(w) 0 1.1])
%pause
