classdef app < handle
    %
    %   Class:
    %   notocord_mpi.app
    
    properties
        file_path
        mpi
    end
    
    methods
        function obj = app(file_path)
            obj.file_path = file_path;
            assembly_path = 'C:\Program Files\NOTOCORD\HEM\Notocord.MPI.dll';
            NET.addAssembly(assembly_path);
            obj.mpi = Notocord.MPI.MPI;
        end
        function info = getInfo(obj)
            [error_code, info_object] = NSGetInfo(obj.mpi, obj.file_path);
            handleErrorCode(obj,error_code)
            raw_info = cell(info_object,'ConvertTypes',{'all'});
            info = notocord_mpi.info(obj,raw_info);
        end
        function fs = getSamplingRate(obj,module_name,stream_name)
            %API doesn't provide this, we'll figure it out through trial
            %and error :/
            sizes = [1e6 1e3 1e9 Inf];
            for i = 1:length(sizes)
                [error_code, time_net, ~] = NSGetData(obj.mpi,obj.file_path, ...
                module_name, stream_name, 0, sizes(i));
                if error_code ~= -17
                    time = double(time_net)/1e6;
                    if length(time) > 2
                        dt = time(2)-time(1);
                        fs = 1/dt;
                        return
                    end
                end
            end
            fs = NaN;
        end
        function [data,time] = getData(obj,module_name,stream_name,start_time,duration)
           [error_code, time_net, data_net] = NSGetData(obj.mpi,obj.file_path, ...
               module_name, stream_name, start_time, duration);
           handleErrorCode(obj,error_code)
           %Assumption ...
           %TODO: can we do some bit division shifting to
           %divide before casting???
           %64 then case then divide again ...
           time = double(time_net)/1e6;
           data = double(data_net);
        end
        function handleErrorCode(obj,error_code)
            
            switch error_code
                case 0
                    %no error
                case -1
                    error('NSS file cannot found')
                case -2
                    %I ran into this when the file was read-only
                    error('NSS file cannot be opened')
                case -3
                    error('File not created')
                    %NSSetData
                    %NSAppendData
                    %NSAppendMarker
                otherwise
                    error('Unhandled error code')
            end
                    
            %{

-2

FILE_LOCKED	
All

NSS file cannot be opened.

-3

FILE_NOT_CREATED	


NSS file cannot be created.

-5	UNEXPECTED_ERROR	All	An unknown error occurred.
-6	GLP_FILE_MODIFICATION_NOT_ALLOWED	NSSetData
NSAppendData
NSAppendMarker	Files recorded under access control cannot be edited.
-7	NATIVE_STREAMS_MODIFICATION_NOT_ALLOWED	NSSetData
NSAppendData
NSAppendMarker	Native module streams cannot be edited (including modules renamed to MATLAB).
-11

STREAM_NOT_FOUND	
NSGetData

Stream doesn't exist.

 -12

STREAM_INVALID_IDENTIFIER	
NSSetData
NSAppendData

Stream type is not recognized or does not match the existing stream type.

-13

STREAM_INVALID_DATA_TYPE	
NSGetData

Stream type is not supported

-14

STREAM_TIME_ERROR	
NSGetData
NSSetData
NSAppendData

At least 1 argument related to Date and Time, Start Time or Duration is incorrect.

-16	INVALID_PERIOD	NSSetData
NSAppendData	Sampling period must be an integer in microseconds.
-17	TOO_MANY_SAMPLES	
NSGetData
NSSetData
NSAppendData
NSAppendMarker

The function has requested more than

3.600.000 data samples for Value-Only, Time-Only and Time-Value streams or
1.000 data samples for Marker, Note, Spectrum, VME Zone and PVL Zone.
-18	STREAM_NAME_TOO_LONG	NSSetData
NSAppendData
NSAppendMarker	Name of the stream exceeds 50 characters.
-100	LICENSE_NOT_PRESENT	All	Installed license does not contain MPI20a token.
            %}
        end
    end
end

