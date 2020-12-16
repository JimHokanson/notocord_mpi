classdef marker < handle
    %
    %   Class:
    %   notocord_mpi.marker
    
    properties (Hidden)
       app 
    end
    
    properties
        module
        stream
        start
        stop
    end
    
    methods
        function obj = marker(app,module_name,stream_name,start,stop)
            obj.app = app;
            obj.module = module_name;
            obj.stream = stream_name;
            obj.start = start;
            obj.stop = stop;
            
        end
        function [strings,times] = getData(obj)
           [strings,times] = obj.app.getMarkerData(obj.module,obj.stream,0,Inf);
        end
    end
end

