function[LFP] = DAVIS_Manual_Artifact_Reject(LFP,Times, window_size_sec,overwrite)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function[LFP] = DAVIS_Manual_Artifact_Reject(LFP,window_size_sec,overwrite)
% LFP        - filename or LFP structure from DAVIS_Pre_Process. If left
% empty or blank it will pull up a gui to select the file.
% window_size - How big a window to look at each time. DEfauklt 30 seconds
% overwrite   - Whether to keep the bad intervals currently in the file(0)
% or completely replace them (1)
% Basic GUI stuff:
% Run with no arguments, this will let you open up a file and start using
% the Define Artifact button to select bad points. You can also click
% outside of the axis to select points not currently in view, like before
% the start of a recording, or in the next or preveious window. At the
% begining it detects the current filename and writes it into the LFP
% structure, for future refrence. It'll ask you ifyou want to use the new
% filename if you've changed it before. Finally, at the end, you can
% overwrite the original file, or just end the program. The LFP structure
%  will still be output.
%  Mattenator 2016.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
LFP_fullpath = [];
if nargin < 1 | isempty(LFP);
    
    [LFP,LFP_fullpath] = uigetfile('Select LFP');
    
end
if ischar(LFP)
    filename = LFP;
    LFP = load([LFP_fullpath LFP]);
    try if ~strcmp(LFP.name,filename);
            button = questdlg('Filename and LFP.name do not agree. Overwrite LFP.name?','Filename Overwrite');
            switch button;
                case 'Yes'
                    LFP.name = filename;
                    disp('Setting name value of LFP to current file name.')
                case 'No'
                case 'Cancel'
                    return
            end
        end
    catch
        LFP.name = filename;
        disp('No name in LFP.')
        disp('Setting name value of LFP to current file name.')
    end
    
end
if nargin < 2
    window_size_sec = 30;
end
if nargin < 3
    overwrite = 0;
end

TS = Times-Times(1);
values = LFP;
badvals = nan(size(LFP));

if isempty(overwrite) || overwrite == 0;
    for i_interval = 1:size(LFP.bad_intervals,1)
        values(...
            floor(LFP.bad_intervals(i_interval,1))...
            :ceil(LFP.bad_intervals(i_interval,2)))...
            = NaN();
        badvals(...
            floor(LFP.bad_intervals(i_interval,1))...
            :ceil(LFP.bad_intervals(i_interval,2)))...
            = LFP.values(...
            floor(LFP.bad_intervals(i_interval,1))...
            :ceil(LFP.bad_intervals(i_interval,2)));
    end
else
    LFP.bad_intervals = [1 2];
end
point_jump = round(window_size_sec*Fs);

ixis = [1:point_jump:length(LFP) length(LFP)];
interf = figure;
i = 2;
figure(interf)
plot(TS(ixis(i-1):ixis(i)),values (ixis(i-1):ixis(i)),'b')
hold on
plot(TS(ixis(i-1):ixis(i)),badvals(ixis(i-1):ixis(i)),'r')
hold on
xlabel('Time (s)')
ylabel('mV')
movegui(interf,'west')
hb = uicontrol('style','pushbutton');
set(hb,'position',[1 1 120 20])
set(hb,'string','Define Artifact')
set(hb,'callback',{@define_artifact,interf})
nw = uicontrol('style','pushbutton');
set(nw,'position',[1 21 120 20])
set(nw,'string','Next Window')
set(nw,'callback',{@next_window,interf})
pw = uicontrol('style','pushbutton');
set(pw,'position',[121 21 120 20])
set(pw,'string','Preveious Window')
set(pw,'callback',{@prev_window,interf})
c = uicontrol('style','pushbutton');
set(c,'position',[121 1 120 20])
set(c,'string','Cancel')
set(c,'callback',{@exit,interf})
    function define_artifact(hb, ~, interf)
        figure(interf)
        hold on
        title('Click Artifact Start')
        [xf(1),~] = ginput(1);
        %x(1) = xf(1) +ixis(i-1);
        [~, x(1)] = min(abs(TS-xf(1)));
        line([xf(1) xf(1)],ylim,'Color',[0 1 0])
        title('Click Artifact End')
        [xf(2),~] = ginput(1);
        %x(2) = xf(2) +ixis(i-1);
        [~, x(2)] = min(abs(TS-xf(2)));
        line([xf(2) xf(2)],ylim,'Color',[1 0 0])
        title('Right Click if OK')
        [~, ~, button] = ginput(1);
        if button == 3;
            LFP.bad_intervals = [LFP.bad_intervals; x;];
            LFP.bad_intervals(LFP.bad_intervals < 1) = 1;
            LFP.bad_intervals(LFP > length(LFP)) = length(LFP);
        else
        end
        for i_interval = 1:size(LFP.bad_intervals,1)
            values(...
                floor(LFP.bad_intervals(i_interval,1))...
                :ceil(LFP.bad_intervals(i_interval,2)))...
                = NaN();
            badvals(...
                floor(LFP.bad_intervals(i_interval,1))...
                :ceil(LFP.bad_intervals(i_interval,2)))...
                = LFP.values(...
                floor(LFP.bad_intervals(i_interval,1))...
                :ceil(LFP.bad_intervals(i_interval,2)));
        end
        hold off
        plot(TS(ixis(i-1):ixis(i)),values (ixis(i-1):ixis(i)),'b')
        hold on
        plot(TS(ixis(i-1):ixis(i)),badvals(ixis(i-1):ixis(i)),'r')
        hold on
        xlabel('Time (s)')
        ylabel('mV')
    end
    function next_window(nw, ~, interf)
        figure(interf)
        hold off
        i = i+1;
        try
            plot(TS(ixis(i-1):ixis(i)),values (ixis(i-1):ixis(i)),'b')
            hold on
            plot(TS(ixis(i-1):ixis(i)),badvals(ixis(i-1):ixis(i)),'r')
            hold on
        catch
            title('End of Recording. Click Cancel')
        end
    end
    function prev_window(nw, ~, interf)
        figure(interf)
        hold off
        i = i-1;
        try
            plot(TS(ixis(i-1):ixis(i)),values (ixis(i-1):ixis(i)),'b')
            hold on
            plot(TS(ixis(i-1):ixis(i)),badvals(ixis(i-1):ixis(i)),'r')
            hold on
            xlabel('Time (s)')
            ylabel('mV')
        catch
            title('No Previous Window.')
            i = i+1;
        end
    end
    function exit(c, ~, interf)
        button = questdlg('Save these bad intervals and changes to file?','LFP Overwrite');
        switch button;
            case 'Yes'
                save([LFP_fullpath LFP.name],'-struct','LFP')
            case 'No'
                disp('The LFP structure is still output into your workspace.')
            case 'Cancel'
                disp('Too bad. You have to restart your cutting')
                return
        end
        close all
        return
    end
end