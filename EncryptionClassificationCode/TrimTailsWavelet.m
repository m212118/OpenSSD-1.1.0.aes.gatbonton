function out = TrimTailsWavelet(data)
  global threshold
  factor = 2000;    % decimation factor
  marker = decimate(data, factor);  % marker vector
  
  % TOWIII: Set threshold to identify event
  % Ch. 4, @ SSD: 0.15 (from Johnspn's original code)
  % Ch. 1, @ Wall:  0.05 worked (6/28/18, 1135)
  % Ch. 1, @ Wall:  0.03 worked (6/28/18, 1315)
%   threshold = 0.00;
%   threshold = 0.15;
threshold = 0.0;
    
  % find left start point
  M = length(marker);
  startN = 1;
  while (startN <= M) && (marker(startN) < threshold)
    startN = startN + 1;
  end

  % find right end point
  endN = length(marker);
  M = 1;
  while (endN >= M) && (marker(endN) < threshold)
    endN = endN - 1;
  end

  if startN >= endN; out = [];
  else
    startN = (startN - 1)*factor + 1;
    endN   = (endN * factor);
    if endN > length(data); endN = length(data); end
    out    = data(startN:endN);
  end


% now do wavelet denoising before sending signal back
lev = 5;
wname = 'sym8';
[out,c2,l2,threshold_Minimax] = wden(out,'rigrsure','h','mln',lev,wname);
