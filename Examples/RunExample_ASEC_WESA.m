% HOW-TO EXAMPLE SCRIPT ON THE USE OF THE EEG AROUSALS DETECTION CODE
%
% INPUT: AN EDF(+) FILE CONTAINING ONE EEG, ONE EMG (chin) AND (OPTIONALLY) ONE ECG DERIVATIONS
%
% OUTPUT: AN EDF+ FILE CONTAINING ANNOTATIONS OF THE DETECTED EEG AROUSAL EVENTS
%
%% The code below is based on the methods described in the following reference(s):
% 
% [1] - I. Fernández-Varela, D. Alvarez-Estevez, E. Hernández-Pereira, V. Moret-Bonillo, 
% "A simple and robust method for the automatic scoring of EEG arousals in
% polysomnographic recordings", Computers in Biology and Medicine, vol. 87, pp. 77-86, 2017
%
% [2] - D. Alvarez-Estevez, I. Fernández-Varela, "Large-scale validation of an automatic EEG arousal detection
% algorithm using different heterogeneous databases", Sleep Medicine, vol. 57, pp. 6-14, 2019 
%
% Copyright (C) 2017-2019 Isaac Fernández-Varela
% Copyright (C) 2017-2019 Diego Alvarez-Estevez

%% This program is free software: you can redistribute it and/or modify
%% it under the terms of the GNU General Public License as published by
%% the Free Software Foundation, either version 3 of the License, or
%% (at your option) any later version.

%% This program is distributed in the hope that it will be useful,
%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%% GNU General Public License for more details.

%% You should have received a copy of the GNU General Public License
%% along with this program.  If not, see <http://www.gnu.org/licenses/>.
clear all
close all

provideHypnogram = 1;

fileName = 'E:\Finalized_WESAdataset_analysis\S004\InterventionPeriod1\EEG\Night01\ProcessedFinal_May20\WESA_EEG_S004_20180604_ffttot_overlap_vis_cyc_art.mat'
data_in=load(fileName)

eeg.raw = data_in.data((1:length(data_in.vissymb)*data_in.fs*20),2);
emg.raw = data_in.data((1:length(data_in.vissymb)*data_in.fs*20),5)-data_in.data((1:length(data_in.vissymb)*data_in.fs*20),6);
eeg.rate = data_in.fs;
emg.rate=data_in.fs;
hypnogram=zeros(1,length(data_in.vissymb));%0=wake, 1=N1, 2=N2, 3=N3, 5=REM
hypnogram(data_in.vissymb=='1')=1;
hypnogram(data_in.vissymb=='2')=2;
hypnogram(data_in.vissymb=='3')=3;
hypnogram(data_in.vissymb=='r')=5;
% (Optional) Hypnogram information can be provided to the algorithm
%            
if provideHypnogram
    % Here we assume the hypnogram is provided using an external EDF+ file
       
    [out.AR, out.F, out.S, out.EEG, out.EMG] = arousalDetection(eeg, emg, hypnogram);
else
    [arousals, ~, ~, ~] = arousalDetection(eeg, emg);
end

% Add scoring info:

arousal_table=struct2table(out.AR);
arousal_table.epoch_start=ceil(arousal_table.startSample/data_in.fs/20);
arousal_table.sleepstage_start=hypnogram(arousal_table.epoch_start)';
arousal_table.epoch_end=ceil(arousal_table.endSample/data_in.fs/20);
arousal_table.sleepstage_end=hypnogram(arousal_table.epoch_end)';