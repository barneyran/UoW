function [ time ] = secToHHhmmss( duration )
%SECTOHHHMMSS converts duration in seconds into human readable string
%
%   time is HHh:mm:ss char vector where HH stands for occupied spaces but
%   not filled with zeros
%
%   [ time ] = secToHHhmmss( duration )
%
%   INPUTS
%     duration  --> duration in seconds
%
%   OUTPUTS
%     time  -->  HHh:mm:ss char vector

sec = mod(duration, 60);
min = mod(floor(duration/60), 60);
h   = floor(duration/3600);

time = sprintf('%3.0f:%02.0f:%02.0f', h, min, sec);
end

