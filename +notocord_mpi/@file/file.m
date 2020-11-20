classdef file < handle
    %
    %   Class:
    %   notocord_mpi.file
    
    %{
        file_path = 'C:\Users\RNEL\Desktop\notocord\180912 180314a_h Rig2.nss';
        file = notocord_mpi.file(file_path);
        channel = file.getChannel('bal','01');
        tic
        [data,start_times] = channel.getData();
        toc
    %}
    
    properties (Hidden)
        app notocord_mpi.app
    end
    
    properties
        info notocord_mpi.info
    end
    
    methods
        function obj = file(file_path)
            obj.app = notocord_mpi.app(file_path);
            obj.info = obj.app.getInfo();
        end
        function getMarker(obj)
            
        end
        function chan = getChannel(obj,module_name,stream_name)
            chan = obj.info.getChan(module_name,stream_name);
        end
    end
end

