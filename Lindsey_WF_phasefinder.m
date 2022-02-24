%inputLFPep input peak theta freq      
Theta_filt = designfilt('bandpassiir','FilterOrder',12, ...
    'HalfPowerFrequency1',thetafreq-2, 'HalfPowerFrequency2',thetafreq+2, ...
    'SampleRate',sFreq,'designmethod', 'butter');

narrow_filt = designfilt('bandpassiir','FilterOrder',12, ...
    'HalfPowerFrequency1',thetafreq-(2*1.2), 'HalfPowerFrequency2',thetafreq+(2*1.2), ... making 20% bigger
    'SampleRate',sFreq,'designmethod', 'butter');

broad_filt = designfilt('bandpassiir','FilterOrder',12, ...
    'HalfPowerFrequency1',1, 'HalfPowerFrequency2',28, ...%based on bellusco
    'SampleRate',sFreq,'designmethod', 'butter');
 
narrow(:,1)=LFPep(:,1);
broad(:,1)=LFPep(:,1);
    narrow(:,2)=filtfilt(narrow_filt,LFPep(:,2));
        broad(:,2)=filtfilt(broad_filt,LFPep(:,2));

    
    theta_phase=[];
    theta_phase(:,1)=LFPep(:,1);
    
    theta_phase(:,2)=angle(hilbert(filtfilt(Theta_filt,LFPep(:,2))));

%PEAK BASED ON FITLERED
[PeaksIdx,TroughsIdx,~, ~] = Find_peaks_troughs_zeros(narrow(:,2));
[~,~,zupix, zdownix] = Find_peaks_troughs_zeros(broad(:,2));

figure;plot(LFPep(:,1),LFPep(:,2))
testix=LFPep(:,1)>3.97e9 & LFPep(:,1)<3.9735e9;

figure;plot(LFPep(testix,1),LFPep(testix,2));
testLFP=LFPep(testix,:);
testnarrow=narrow(testix,:);
testbroad=broad(testix,:);

[PeaksIdx,TroughsIdx,~, ~] = Find_peaks_troughs_zeros(testnarrow(:,2));
 [pkix,pks]= findpeaks(testnarrow(:,2),testnarrow(:,1)); %now locs is expressed in time
 [pkvals,pkix]= findpeaks(testnarrow(:,2)); %now locs is expressed in time

 
 [trix,trg]= findpeaks(-(testnarrow(:,2)),testnarrow(:,1)); %now locs is expressed in time
 [trvals,trix]= findpeaks(-(testnarrow(:,2))); %now locs is expressed in time

%narrow now just needs to back the peaks and troughs up to the nearest
%actual peak in broad

[~,~,zupix, zdownix] = Find_peaks_troughs_zeros(testbroad(:,2));
figure
plot(testLFP(:,1),testLFP(:,2))
hold on
plot(testnarrow(:,1),testnarrow(:,2),'k')
plot(testbroad(:,1),testbroad(:,2),'g')

plot(testLFP(pkix,1),testLFP(pkix,2),'ob')
plot(testLFP(pkix,1),testLFP(trix,2),'ob')
plot(testLFP(zupix,1),testLFP(zupix,2),'or')
plot(testLFP(zdownix,1),testLFP(zdownix,2),'or')

                [~,locs]= findpeaks(narrow(:,2),narrow(:,1)); %now locs is expressed in time
                centerpeak=ceil(length(locs)/2);
                theta_peak=locs(centerpeak);
                theta_peakm1=locs(centerpeak-1);
                theta_peakp1=locs(centerpeak+1);

        %trough  1 and 2 based on theta   
                [~,locs2]= findpeaks(-(filtered_theta(time_ix,2)),LFPep(time_ix,1)); %now locs is expressed in time
                backix=locs2<theta_peak;
                theta_trough=max(locs2(backix));
                frontix=locs2>theta_peak;
                theta_trough2=min(locs2(frontix));
                
       %ninety degress
            snip= Restrict(broad_filtered,theta_trough,theta_peak);
             ninety_ix=dsearchn(snip(:,2),0);
            ninety_time=snip(ninety_ix,1);

       %180 degrees
       %find second trough, then same as for 90
                snip2= Restrict(broad_filtered,theta_peak,theta_trough2);
             oneeighty_ix=dsearchn(snip2(:,2),0);
            oneeighty_time=snip2(oneeighty_ix,1);
            
       %zero degrees
       snip3=Restrict(broad_filtered,theta_peakm1,theta_trough);
              zero_ix=dsearchn(snip3(:,2),0);
            zero_time=snip3(zero_ix,1);
            
         %two70 degrees
       snip4=Restrict(broad_filtered,theta_trough2,theta_peakp1);
              two70_ix=dsearchn(snip4(:,2),0);
            two70_time=snip4(two70_ix,1);          

            
            % NOW REAL PEAK BASED ON MAX and MIN between zero crossings
            Wave_area=Restrict(broad_filtered,ninety_time,oneeighty_time);
            [val,ix]=max(Wave_area(:,2));
            time_peak=Wave_area(ix,1);
            
            %real trough 1 base on zero and 90
            Wave_area=Restrict(broad_filtered,zero_time,ninety_time);
            [val,ix]=min(Wave_area(:,2));
            time_trough=Wave_area(ix,1);
            
            %real trough 2
            Wave_area=Restrict(broad_filtered,oneeighty_time,two70_time);
            [val,ix]=min(Wave_area(:,2));
            time_trough2=Wave_area(ix,1);    
            
            
             Quad1_us= ninety_time-time_trough  ; %Quad 1: Trough 1 to ninety
            Qaud2_us= time_peak-ninety_time ;   %Quad 2: Ninety to peak
            Quad3_us= oneeighty_time-time_peak ;  %Quad 3: Peak to 180
             Quad4_us=time_trough2-oneeighty_time;   %Quad 4: 180 to trough 2