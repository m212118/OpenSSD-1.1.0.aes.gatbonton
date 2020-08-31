function [startindex,stopindex]=FindActivity(y)
% This function finds the beginning and ending index of each portion of a
% read or write activity and returns an array with the start and stop
% indices.

w=y.*y;
%w=w(100000:end);    % trim off first part of file
filterlength=1000;
w=filter(ones(1,filterlength)*1/filterlength,1,w);
th=max(w)*.4;mask=(zeros(size(w)));
mask(find(w>th))=1;

% now use the diff function to find the transitions from 1 to 0 and vice
% versa, where the first element of diff(x) = x(2)-x(1). In the following,
% "transitions" is an array of -1s, +1s and 0s. If a transition is a -1,
% then the transition is from high to low, +1 means low to high, and 0
% means no transition.
transitions = diff(mask);
rise=find(transitions == 1);, fall=find(transitions == -1);
% now check if there are the same # of rises as falls...if not, then the
% signal starts > threshold already, or ends > threshold. Add the index 1
% to the beginning of rise, or the end index of the signal to the
% end of fall.%     

if length(rise) < length(fall)    % # rises > # falls
    rise=[1 rise];   % let the first index of rise = 1 (beginning of signal)
elseif length(fall) < length(rise)
    fall=[fall length(mask)];  % let the last index of fall = end index
elseif mask(1)==1 % It is possible that the original # of rises = original # of falls, 
    % but the beginning and end of signal is high, so we lose the first
    % and last index
    rise=[1 rise];
    fall=[fall length(mask)];
end

% at this point, both the rise and fall arrays have the same # of elements
% and we've accounted for the case where the signal begins and ends high.
for k=1:length(rise)
    startindex(k)=rise(k);
    stopindex(k)=fall(k);
end

d=zeros(length(mask),1);
for k=1:length(rise)
    d(startindex(k):stopindex(k))=1;
end
%  figure(2), subplot(2,1,1),plot(w)
%  subplot(2,1,2),plot(d),axis([1 length(w) 0 1.1])
%pause
