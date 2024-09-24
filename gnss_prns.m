% Clear the workspace, clear the display, and close all figures...
clear;
home;
close all; 

% Set a few constants 
OVERSAMPLE_RATE = 10; 
MIN_SV = 1; 
MAX_SV = 37; 
SV_NUM = 10; 
SNR = 0.01; 
INTEGRATION_TIME = 50; 
MAX_CORR_GAIN = 1023 * OVERSAMPLE_RATE; 

% Generate the PRNs for all space vehicles and show first few values 
prn_codes = cacode(MIN_SV:MAX_SV, 1); 
disp(prn_codes(1:5, 1:10));

% Clear that set of PRNs and re-generate at a higher sample rate 
clear prn_codes; 
prn_codes = cacode(MIN_SV:MAX_SV, OVERSAMPLE_RATE); 
plot(prn_codes(1, 1:50*OVERSAMPLE_RATE));
axis([1, 50*OVERSAMPLE_RATE, -0.1, 1.1]); 
title('First 50 Chips of PRN #1'); 

% Convert from [0, 1] to [-1, 1]
prn_codes(prn_codes(:,:)==0)= -1; 

% Test the balance of the PRNs (plot the sums of the vectors) 
sums = zeros(1, MAX_SV - MIN_SV + 1); 
for i = MIN_SV:MAX_SV 
    sums(i) = sum(prn_codes(i, :)); 
end 
figure; 
stem(sums); 
title('Balance of 1s and -1s in PRN codes'); 
axis([MIN_SV, MAX_SV, -1023, 1023]); 

% Create noisy signal containing a single PRN 
noise_sig = randn(1, length(prn_codes(1,:))); %Note: normally distributed
figure; 
plot(noise_sig, 'b'); 
title('Noise Level vs Signal Level'); 
axis([1,length(noise_sig), 1.1*min(noise_sig), 1.1*max(noise_sig)]); 
noise_amplitude = max(noise_sig) - min(noise_sig); 
prn_amplitude = max(prn_codes(SV_NUM, :)) - min(prn_codes(SV_NUM, :)); 
SNR_FACTOR = SNR * (prn_amplitude / noise_amplitude);
sv_sig = prn_codes(SV_NUM, :) .* SNR_FACTOR; 
hold on; 
plot(sv_sig, 'r'); 
rx_sig = noise_sig + sv_sig; 

% Compute the autocorrelation 
accum_sig = zeros(1, length(rx_sig)); 
corr_gain = zeros(1, INTEGRATION_TIME);
corr_sig = zeros(1, length(rx_sig));
for i = 1:INTEGRATION_TIME
    noise_sig = randn(1, length(prn_codes(1,:)));
    sv_sig = prn_codes(SV_NUM, :) .* SNR_FACTOR; 
    rx_sig = noise_sig + sv_sig; 
    accum_sig = (accum_sig + rx_sig) .* prn_codes(SV_NUM, :);
    for j = 1:length(accum_sig) 
        if (accum_sig(1, j) > 0) 
            corr_sig(j) = 1; 
        end 
    end
    corr_gain(i) = sum(corr_sig) ./ MAX_CORR_GAIN; 
end

% Plot the progression of the correlation gain
hold off;
figure; 
plot(corr_gain, 'b'); 
axis([1, INTEGRATION_TIME, 0, 1]); 
title('Correlation Gain w/ Integration Time'); 
