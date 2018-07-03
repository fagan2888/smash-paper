function out = ThreshWaveb(Noisy,type,TI,sigma,mult,L,qmf) 

%  ThreshWave:  Denoising of 1-d signal with wavelet thresholding.
%  Usage 
%               out = ThreshWaveb(Noisy,type,TI,sigma,mult,L,qmf)
%  Inputs
%    Noisy	    1-d Noisy signal, length(Noisy)= 2^J.
%    type   	 'S' for soft thresholding, 'H' for hard thresholding.
%		          Optional, default=hard thresholding.
%    TI		    Enter 1 if you want translation-invariant denoising,
%		          0 if you don't. Optional, default=non-invariant. 
%    sigma  	 Standard deviation of additive Gaussian White Noise.
%	             Enter 0 if you want sigma to be estimated by median filtering.
%		          Optional, default=estimated by median filtering.
%    mult   	 Multiplier of sigma to obtain the value of the threshold.
%           	 Optional, default = sqrt(2*log(n)), where n is the length of data.
%    L      	 Low-Frequency cutoff for shrinkage (e.g. L=4). Should have L << J!
%           	 Optional, default = 3.
%    qmf    	 Quadrature mirror filter for wavelet transform.
%           	 Optional, default = Symmlet 4.
%  Outputs 
%    out     	 Estimate, obtained by applying thresholding on the wavelet 
%               coefficients.

  n=length(Noisy);
  if nargin < 7,
      qmf = MakeONFilter('Symmlet',4);
  end
  if nargin < 6,
      L = 3;
  end
  if nargin < 5,
      mult = sqrt(2*log(n));
  end
  if nargin < 4,
      [y,coef] = NormNoise(Noisy,qmf);
      sigma=1/coef;
  end
  if nargin < 3,
      TI = 0;
  end
  if nargin < 2,
      type = 'H';
  end

  if sigma==0,
      [y,coef] = NormNoise(Noisy,qmf);
      sigma=1/coef;
  end

  thresh= sigma*mult;
  out=zeros(1,n);
  
  if TI==1,
	nspin =8;
	for i=0:(nspin-1),
		[Noistrans]  = cyclespin(Noisy,  i);
		wcoef = FWT_PO(Noistrans,L,qmf) ;
		if strcmp(type,'S'),
			wcoef_thresh = SoftThresh(wcoef,thresh);
  		else
			wcoef_thresh = HardThresh(wcoef,thresh);
  		end
		dout    = IWT_PO(wcoef_thresh,L,qmf);
		[dout]  = cyclespin(dout,  -i);
		out = out+dout;
	end
	out  = out/nspin;
  else
	wcoef = FWT_PO(Noisy,L,qmf) ;
	wcoef_thresh = wcoef;

	if strcmp(type,'S'),
		% Thresholding of the wavelet coefficients above the level L !!!
		wcoef_thresh((2^(L)+1):n) = SoftThresh(wcoef((2^(L)+1):n),thresh);
  	else
		% Thresholding of the wavelet coefficients above the level L !!!
		wcoef_thresh((2^(L)+1):n) = HardThresh(wcoef((2^(L)+1):n),thresh);
  	end
	
  	out = IWT_PO(wcoef_thresh,L,qmf);
  end

% Written by Maureen Clerc and Jerome Kalifa, 1997
% clerc@cmapx.polytechnique.fr, kalifa@cmapx.polytechnique.fr
%   
% Part of WaveLab Version 802
% Built Sunday, October 3, 1999 8:52:27 AM
% This is Copyrighted Material
% For Copying permissions see COPYING.m
% Comments? e-mail wavelab@stat.stanford.edu
   
     