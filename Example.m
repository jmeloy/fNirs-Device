% There are currently four ways to analyze neurofeedback data
% To change what data is being collected, select the Command Window and
% press ctrl + c. Then, clear all and start over as usual.
clc
clear all

%% Amplitude
% 1. Manually select the channels in Turbo-Satori for analysis
% 2. Run the following line
Neurofeedback.Amplitude;

%% Derivative
% 1. Manually select the channels in Turbo-Satori for analysis
% 2. Run the following line
Neurofeedback.Derivative;

%% Correlation & Anti-Correlation
% 1. Manually select the first channel(s) to be compared in Turbo-Satori
% 2. Run the following line
Neurofeedback.SelectChannels1;

% 3. Manually select the second channel(s) to be compared in Turbo-Satori
% 4. Run the following line
Neurofeedback.SelectChannels2;

% 5.1 Run the following line if you want the Correlation
Neurofeedback.Correlation;
% 5.2 Run the following line if you want the Anti-Correlation
Neurofeedback.AntiCorrelation;

% Note: For the correlations, it takes ~20-30 seconds to start up
