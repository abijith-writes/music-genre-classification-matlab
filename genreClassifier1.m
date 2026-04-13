clc;
clear;
close all;

[file, path] = uigetfile({'*.wav;*.mp3'}, 'Select an audio file');

if isequal(file,0)
    disp('No file selected');
    return;
end

[x, fs] = audioread(fullfile(path, file));

if size(x,2) == 2
    x = mean(x, 2);
end

clip_duration = 10; 
mid_point = floor(length(x)/2);

start_idx = max(1, mid_point - floor((clip_duration * fs)/2));
end_idx = min(length(x), start_idx + clip_duration * fs - 1);

x = x(start_idx:end_idx);

player = audioplayer(x, fs);
play(player);

t = (0:length(x)-1)/fs;
figure;
plot(t, x);
xlabel('Time (s)');
ylabel('Amplitude');
title('Audio Waveform');
grid on;

zcr = sum(abs(diff(sign(x)))) / length(x);

X = abs(fft(x));
X = X(1:floor(length(X)/2)); 
f = linspace(0, fs/2, length(X));

centroid = sum(f'.*X) / sum(X);
energy = sum(x.^2)/length(x);

disp(['ZCR = ', num2str(zcr)]);
disp(['Centroid = ', num2str(centroid)]);
disp(['Energy = ', num2str(energy)]);

if centroid < 2500 && zcr < 0.08
    genre = 'Classical';

elseif zcr > 0.13 && energy < 0.01
    genre = 'Pop';

elseif centroid > 3000 && zcr > 0.12
    genre = 'Rock';

else
    genre = 'Melody';
end

disp(['Predicted Genre: ', genre]);
msgbox(['Predicted Genre: ', genre], 'Genre Classification Result');

figure;
plot(f, X);
xlabel('Frequency (Hz)');
ylabel('Magnitude');
title('Frequency Spectrum');
grid on;

disp(['Selected File: ', file]);