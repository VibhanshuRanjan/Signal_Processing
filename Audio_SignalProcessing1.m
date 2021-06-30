%% Program to take an audio file as input and use it
clc;
clearvars;

%% Add path where the audio file is located
addpath('F:\Signal_Processing\');

%% Reading the audio file and store it in a variable
path = 'F:\Signal_Processing\';
fname='audio.wav';
inputFileName = char(strcat(path,fname));
[ipSound,Fs]=audioread(inputFileName,'native');
%% Plot the audio signal
L=length(ipSound);% Total number of samples present in the audio clip

figure(1);
tvec=(0:L-1)/Fs;
plot(tvec,ipSound(:,1)); % for channel 1 of the stereo microphone
title('Amplitude vs time plot of the audio signal');
xlabel('time(s)');
ylabel('magnitude');


figure(2);
stem(ipSound(:,1)); %for channel 1 of the stereo microphone
% stem(ipSound(:,2));%for channel 2 of the stereo microphone 
title('stem plot of the audio signal')
xlabel('sample number');
ylabel('magnitude');

%% Frequency spectrum (FFT) of the sound signal
% Fs = 44100;   %Sampling frequency
T = 1/Fs;       %Sampling period
L = 220500;     %Length of signal(Duration(5s)*Fs)
% L = 1024;
t = (0:L-1)*T;  %Time vector

X=ipSound;      %input signal samples
Y=fft(X);       %using inbuilt fft function

% To obtain the single sided spectrum we are taking half the samples from
% starting 

P2=abs(Y/L);
P1=P2(1:L/2+1);
P1(2:end-1)=2*P1(2:end-1);

f=Fs*(0:(L/2))/L;

figure(3);
plot(f,P1);
title('Single-Sided Amplitude Spectrum of X(t)')
xlabel('f (Hz)');
ylabel('|P1(f)|');

%% Downsample the signal
%Sometimes we ignore higher frequencies which represent noisy component in the audio signal
sampling_factor=4;
Fs_new=Fs/sampling_factor;

ipSound_downsampled=downsample(ipSound,sampling_factor);

%% Plot the downsampled audio signal
L=length(ipSound_downsampled); %Total number of samples present in the audio clip

figure(4);
tvec=(0:L-1)/Fs_new;
plot(tvec,ipSound_downsampled(:,1));
title('Amplitude vs time plot of the downsampled audio signal');
xlabel('time(s)');
ylabel('magnitude');

figure(5);
stem(ipSound_downsampled(:,1));
title('stem plot of the downsampled audio signal');
xlabel('sample number');
ylabel('magnitude');

%% Frequency spectrum (FFT) of the sound signal

%Fs = 44100;                    % Sampling frequency
T = 1/Fs_new;                   % Samping period
L = length(ipSound_downsampled);        % Length of signal
% L = 1024;
t = (0:L-1)*T;          % Time vector

X = ipSound_downsampled; % input signal samples
Y = fft(X);

L = 65536;
Y = fft(X,L);
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);

f = Fs_new*(0:(L/2))/L;

figure(6);
plot(f,P1);
title('Single-Sided Amplitude Spectrum of downsampled X(t)');
xlabel('f (Hz)');
ylabel('|P1(f)|');

%% Bin averaging to reduce Feature vector dimension 

%{
Why reducing feature vector dimension?
-Just a 5sec audio sound can have lakhs of sampled values,which will slow it to train neural
networks(for eg.- classifying between audio with and without background
noise) on feature vector. So it's safe to average out the values to reduce feature vector dimension as we are
not going to loose information until we have sufficient length of data
%}

bin_width = 512;  
%bin_width=1024;

bins = floor(length(P1)/bin_width);

      st = 1;
      en = st+(bin_width-1);
      
      for i=1:1:bins
          avg_bin = (sum(P1(st:en))/bin_width);
          FV(1,i) = avg_bin;
          st=en+1;
          en=st+(bin_width-1);
      end

