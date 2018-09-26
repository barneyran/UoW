function [  ] = dispProgress( numCurrentProcessed, numCurrent, numProcessedTotal, numTotal, elapsedTimeTotal, barSize )
%DISPPROGRESS display the progression of a process, loading bar style
%
%   Display the progression of a process - consisting of numTotal tasks -,
%   separated in different sub processes - each one consisting of 
%   numCurrent tasks -, by showing a progress bar for the current sub 
%   process, and another for the whole process. 
%   It also gives the remaining processing time based on a linear 
%   estimation given the already elapsed time, i.e. assuming each one of
%   the numTotal tasks are approximately the same duration
%
%
%   [  ] = dispProgress( numCurrentProcessed, numCurrent, numProcessedTotal, numTotal, elapsedTimeTotal, barSize )
%
%
%   INPUTS
%     numCurrentProcessed  --> number of tasks already processed in the
%                              current sub process
%     numCurrent           --> total number of tasks in the current 
%                              subprocess 
%     numProcessedTotal    --> number of tasks already processed in the
%                              whole process
%     numTotal             --> total number of tasks in the whole process
%     elapsedTimeTotal     --> total elapsed time since the beginning of
%                              the whole process
%     barSize              --> number of '=' signs constituting the
%                              progress bar
%     
%
%   FUNCTIONS USED
%     dispstat  from scripts\toolboxes\dispstat\
%
%   See also
%     dispstat


% Percentage calculation
percent      = numCurrentProcessed / numCurrent;
percentTotal = numProcessedTotal / numTotal;


% Directorie progression
msg11 = sprintf('Processing : %5.1f %% ', percent*100);
msg12 = [ '[' repmat(' ', 1, barSize) ']' ];
bar1  = repmat('=', 1, floor(percent*barSize));
msg12(2:2+size(bar1,2)-1) = bar1;

msg1 = [msg11 msg12 newline];


% Overall progression
msg21 = sprintf('   Overall : %5.1f %% ', percentTotal*100);

msg22 = [ '[' repmat(' ', 1, barSize) ']'];
bar2  = repmat('=', 1, floor(percentTotal*barSize));
msg22(2:2+size(bar2,2)-1) = bar2;

durMean  = elapsedTimeTotal / numProcessedTotal;

msg23 = [ ' (for ' secToHHhmmss(elapsedTimeTotal) ' | ' secToHHhmmss(durMean*(numTotal-numProcessedTotal)) ' remaining)' ];

msg2 = [msg21 msg22 msg23 newline];


% Final display
msg = [msg1 msg2];
dispstat(msg);

end

