classdef info
    %
    %   Class:
    %   notocord_mpi.info
    
    properties (Hidden)
        app
    end
    
    properties
        unique_modules
        unique_types
        table
        module_names
        stream_names
    end
    
    methods
        function obj = info(app,raw_info)
            obj.app = app;
            
            s = struct();
            s.id = (1:(size(raw_info,1)-1))';
            %We start at 2 because info has headers
            s.module = raw_info(2:end,1);
            s.stream = raw_info(2:end,2);
            s.type = raw_info(2:end,3);
            s.unit = raw_info(2:end,4);
            s.start = cellfun(@(x) x/1e6,raw_info(2:end,5),'un',0);
            s.stop = cellfun(@(x) x/1e6,raw_info(2:end,6),'un',0);
            
            obj.table = struct2table(s);
            
            obj.unique_modules = unique(obj.table.module);
            obj.unique_types = unique(obj.table.type);
            
            obj.module_names = obj.table.module;
            obj.stream_names = obj.table.stream;
            
            %{
            Module name
Name of the module the stream belongs to.

Streamer name
Name of the stream (module output).

Type
Value-only types: VInt16, VInt32, VFloat32, VFloat64 (16-bit integer, 32-bit integer, 32-bit floating number or 64-bit floating number).
Time-only type: TimeOnly (64-bit integer).
Time-Value types: TVInt16, TVInt32, TVFloat64 (16-bit integer, 32-bit integer or 64-bit floating number).
Other types: 'Marker', 'Note', 'Blob', 'Video'.
Unit
Stream unit.
Reported as '0x0 char' when empty.

Start
Stream start time, in microseconds, relative to the beginning of the file.
Reported as 'NaN' (Not a Number) for empty streams.

End
Stream end time, in microseconds, relative to Start.
Reported as 'NaN' for empty streams.
            %}
        end
        function out = getStream(obj,I)
            type = obj.table.type{I};
            switch type
                case 'Marker'
                    out = obj.getMarker(I);
            end
        end
        function marker = getMarker(obj,module_name_or_I,stream_name,varargin)
            in.partial = true;
            in.case_sensitive = false;
            in = notocord_mpi.sl.in.processVarargin(in,varargin);
            
            
            if isnumeric(module_name_or_I)
                I = module_name_or_I;
            else
                is_writeable = strcmp(module_name_or_I,'MATLAB');
                missing_ok = is_writeable;
                I = h__getIndex(obj,module_name_or_I,stream_name,in,missing_ok);
            end
            
            if isempty(I)
                module = 'MATLAB';
                stream = stream_name;
                start = 0;
                stop = 0;
            else
                module = obj.module_names{I};
                is_writeable = strcmp(module,'MATLAB');
                stream = obj.stream_names{I};
                type = obj.table.type{I};
                %units = obj.table.unit{I};
                start = obj.table.start{I};
                stop = obj.table.stop{I};
            end
            
            %TODO: Confirm marker type 
            if is_writeable
                marker = notocord_mpi.writeable_marker(obj.app,module,stream,start,stop);
            else
                marker = notocord_mpi.marker(obj.app,module,stream,start,stop);
            end
        end
        function chan = getChan(obj,module_name,stream_name,varargin)
            
            in.partial = true;
            in.case_sensitive = false;
            in = notocord_mpi.sl.in.processVarargin(in,varargin);
            
            missing_flag = false; %not OK to be missing
            I = h__getIndex(obj,module_name,stream_name,in, missing_flag);
            
            module = obj.module_names{I};
            stream = obj.stream_names{I};
            type = obj.table.type{I};
            units = obj.table.unit{I};
            start = obj.table.start{I};
            stop = obj.table.stop{I};
            
            %TODO: Support types:
            %--------------------------------------
            % Value-only types: VInt16, VInt32, VFloat32, VFloat64 (16-bit integer, 32-bit integer, 32-bit floating number or 64-bit floating number).
            % Time-only type: TimeOnly (64-bit integer).
            % Time-Value types: TVInt16, TVInt32, TVFloat64 (16-bit integer, 32-bit integer or 64-bit floating number).
            % Other types: 'Marker', 'Note', 'Blob', 'Video'.
            
            chan = notocord_mpi.channel(obj.app,module,stream,type,units,start,stop);
            
            %type = obj.table.type
            %         s.type = raw_info(2:end,3);
            %s.unit = raw_info(2:end,4);
            %s.start = raw_info(2:end,5);
            %s.stop = raw_info(2:end,6);
            
        end
    end
end

function I = h__getIndex(obj,module_name,stream_name,in,missing_ok)

%Insensitive match
%Partical match
if in.partial
    if in.case_sensitive
        fh = @contains;
    else
        fh = @(x,y)contains(x,y,'IgnoreCase',true);
    end
else
    if in.case_sensitive
        fh = @strcmp;
    else
        fh = @strcmpi;
    end
end
I = find(fh(obj.module_names,module_name) & fh(obj.stream_names,stream_name));
if isempty(I)
    if ~missing_ok
        error('Unable to find any match for module: %s and stream: %:s',...
            module_name,stream_name);
    end
elseif length(I) > 1
    error('Multiple matches (%d) for module: %s and stream: %:s',...
        length(I),module_name,stream_name);
end
end

