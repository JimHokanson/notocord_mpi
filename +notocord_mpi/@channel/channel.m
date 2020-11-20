classdef channel < handle
    %
    %   Class:
    %   notocord_mpi.channel
    
    properties (Hidden)
        app notocord_mpi.app
    end
    
    properties
        module
        stream
        type
        units
        start
        stop
        duration
        fs
        n_samples
    end
    
    
    
    methods
        function obj = channel(app,module,stream,type,units,start,stop)
            obj.app = app;
            obj.module = module;
            obj.stream = stream;
            obj.type = type;
            obj.units = units;
            obj.start = start;
            obj.stop = stop;
            obj.duration = stop - start;
            obj.fs = obj.app.getSamplingRate(module,stream);
            obj.n_samples = obj.fs*obj.duration;
        end
        function [final_data,start_times] = getData(obj,varargin)
            %TODO: Support samples as well ...
            in.time_range = [obj.start obj.stop];
            in = notocord_mpi.sl.in.processVarargin(in,varargin);
            
            
            start_time = in.time_range(1);
            stop_time = in.time_range(2);
            SAMPLE_LIMIT = 3600000; %Why??? 
            %Could do error checking here ...
            requested_duration = stop_time-start_time;
            n_samples_requested = obj.fs*requested_duration;
            n_chunks = ceil(n_samples_requested/SAMPLE_LIMIT);
            time_per_limit = SAMPLE_LIMIT/obj.fs;
            %What time occupies 3600000
            starts = start_time:time_per_limit:stop_time;
            starts_us = starts*1e6;
            durations = starts_us;
            durations(:) = time_per_limit;
            durations(end) = stop_time-starts(end);
            durations_us = durations*1e6;
            
            all_data = NaN(1,n_samples_requested);
            all_time = NaN(1,n_samples_requested);
            stop_I = 0;
            for i = 1:n_chunks
                cur_start = starts_us(i);
                cur_duration = durations_us(i);
                [data,time] = obj.app.getData(obj.module,obj.stream,cur_start,cur_duration);
                start_I = stop_I + 1;
                stop_I = stop_I + length(data);
                all_data(start_I:stop_I) = data;
                all_time(start_I:stop_I) = time;
            end
            %Ick, this is awful for memory, although storing time is bad as
            %well :/
            %TODO: We don't need to do this if we don't have a gap ...
            dt = 1/obj.fs;
            %Floating point comparison ...
            time_gap_I = find(diff(all_time) - dt > 1e-9);
            start_samples = [1 time_gap_I+1];
            stop_samples = [time_gap_I stop_I];
            n_gaps = length(start_samples);
            start_times = time(start_samples);
            final_data = cell(1,n_gaps);
            for i = 1:n_gaps
                final_data{i} = all_data(start_samples(i):stop_samples(i));
            end
        end
    end
end

