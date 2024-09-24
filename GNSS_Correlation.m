%Made by Jim; altered by Matt

% Clear the workspace, clear the display, and close all figures...
clear;
home;
close all; 

% Set a few constants 
OVERSAMPLE_RATE = 1; %10; 
MIN_SV = 1; 
MAX_SV = 37; 
SV_NUM = 10; 
SNR = 0.01; 
INTEGRATION_TIME = 20; %50; 
MAX_CORR_GAIN = 1023 * OVERSAMPLE_RATE; 

% Generate the PRNs for all space vehicles and show first few values 
prn_codes = cacode(MIN_SV:MAX_SV, 1); 

% Convert from [0, 1] to [-1, 1]
prn_codes(prn_codes(:,:) == 0) = -1; 

%Compute SNR_FACTOR
noise_sig = randn(1, length(prn_codes(1,:))); %Note: normally distributed
noise_amplitude = max(noise_sig) - min(noise_sig); 
prn_amplitude = max(prn_codes(SV_NUM, :)) - min(prn_codes(SV_NUM, :)); 
SNR_FACTOR = SNR * (prn_amplitude / noise_amplitude);

%Note: perform part 1 of assignment 1
%-----------------------------------%

part1_dataset = zeros(MAX_SV, INTEGRATION_TIME);

for h = MIN_SV:MAX_SV

    sv_sig = prn_codes(h, :) .* SNR_FACTOR; 
    rx_sig = noise_sig + sv_sig; 

    % Compute the auto-correlation 
    accum_sig = zeros(1, length(rx_sig)); 
    corr_gain = zeros(1, INTEGRATION_TIME);
    corr_sig = zeros(1, length(rx_sig));
    for i = 1:INTEGRATION_TIME
        noise_sig = randn(1, length(prn_codes(1,:)));
        sv_sig = prn_codes(h, :) .* SNR_FACTOR; 
        rx_sig = noise_sig + sv_sig; 
        accum_sig = (accum_sig + rx_sig) .* prn_codes(h, :);
        for j = 1:length(accum_sig) 
            if (accum_sig(1, j) > 0) 
                corr_sig(j) = 1; 
            end 
        end
        corr_gain(i) = sum(corr_sig) ./ MAX_CORR_GAIN; 
    end

    part1_dataset(h, :) = corr_gain(:);
end

figure; surf(part1_dataset');
xlabel('PRN Number');
ylabel('Integration Counter');
zlabel('Auto-Correlation Gain');
title('Time Integration w/ Auto-Correlation Case');

%-----------------------------------%

%Note: perform part 2 of assignment 1
%-----------------------------------%

part2_dataset = zeros(MAX_SV, MAX_SV);
part2_dataset_no_noise = zeros(MAX_SV, MAX_SV);

for h = MIN_SV:MAX_SV

    sv_sig = prn_codes(h, :) .* SNR_FACTOR; 
    rx_sig = noise_sig + sv_sig; 

    for g = MIN_SV:MAX_SV
        
        % Compute the auto-correlation 
        noise_sig = randn(1, length(prn_codes(1,:)));
        sv_sig = prn_codes(h, :); 
        rx_sig = sv_sig + noise_sig;
        
        rx_local_replica = prn_codes(g, :);

        xcorr_gain_no_noise = max(xcorr(prn_codes(h, :), prn_codes(g, :), 'normalized')); %perfect case - no noise
        
        %xcorr_gain = max(xcorr(rx_sig, rx_sig1, 'normalized')); %sorta works but odd that the cross correlation of off diagnols are so high...
        xcorr_gain = max(xcorr(rx_sig, rx_local_replica)) / MAX_CORR_GAIN;
        
        %part2_dataset(h, g) = xcorr_gain;
        part2_dataset(h, g) = 10*log10(xcorr_gain); %wants zeros on diagonals so convert to dB
        
        %part2_dataset_no_noise(h, g) = xcorr_gain_no_noise;
        part2_dataset_no_noise(h, g) = 10*log10(xcorr_gain_no_noise); %wants zeros on diagonals so convert to dB
    end

end

figure; surf(part2_dataset');
xlabel('TX PRN Number');
ylabel('RX PRN Number');
zlabel('Cross-Correlation Gain [dB]');
title('Noisy Case');

figure; surf(part2_dataset_no_noise');
xlabel('TX PRN Number');
ylabel('RX PRN Number');
zlabel('Cross-Correlation Gain [dB]');
title('No Noise Case');

%-----------------------------------%

%Note: perform part 3 of assignment 1
%-----------------------------------%

% The abnormalities seen at [34,37] and [37,34] are due to the shared usage
% of the same PRN sequences. In C/A code there are 36 unique PRN
% sequences. However there are actually 37 PRN C/A codes, but 34 and 37
% share the same code. These C/A codes are a subset known as Gold codes named after the
% inventor. The reason for the sharing of the codes may have to do with the
% satellites utilizing PRN 34 and 37 oribital locations. Furthermore the
% sharing of the PRN code could also be due to a scientific experiment
% where the developers wanted to study the interference interactions on the
% GPS receivers related to having both satellites in field of view of
% receiver that utilize the same PRN code.

%-----------------------------------%

