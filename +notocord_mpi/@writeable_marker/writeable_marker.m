classdef writeable_marker < notocord_mpi.marker
    %
    %   Class:
    %   notocord_mpi.writeable_marker
    
    properties
    end
    
    methods
        function obj = writeable_marker(app,module_name,stream_name,start,stop)
            obj = obj@notocord_mpi.marker(app,module_name,stream_name,start,stop);
        end
        
        function appendEvents(obj,strings,times)
            %TODO: We could support a null string expansion if times
            %is much longer
            %
            %   e.g. ('',1:3)
            if ischar(strings)
                strings = {strings};
            end
            
            if length(times) ~= length(strings)
                if length(strings) == 1
                    %TODO: replicate
                    error('replication not yet implemented')
                else
                    error('mismatch in times and strings length')
                end
            end
            
            obj.app.appendEvents(obj.stream,strings,times)
        end
    end
end

