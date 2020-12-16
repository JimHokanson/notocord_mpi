classdef file < handle
    %
    %   Class:
    %   notocord_mpi.file
    
    %{
        file_path = 'C:\Users\RNEL\Desktop\notocord\180912 180314a_h Rig2.nss';
        file = notocord_mpi.file(file_path);
        marker = file.getMarker('KBD',' 2');
        marker = file.getStream(1);
        [s,t] = marker.getData();
        channel = file.getChannel('bal','01');
        tic
        [data,start_times] = channel.getData();
        toc
    
        file_path = 'C:\Users\RNEL\Desktop\notocord\180912 180314a_h Rig2 - Copy.nss';
        file = notocord_mpi.file(file_path);
        marker = file.getWriteableMarker('testing1');
        tic
        marker.appendEvents({'test','cheese','beer'},[1 10 30])
        toc
    
        file.refresh();
        marker = file.getMarker('MATLAB','testing1');
        [s,t] = marker.getData();
        
        
    
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
        function refresh(obj)
            obj.info = obj.app.getInfo();
        end
        function out = getStream(obj,index)
            out = obj.info.getStream(index);
        end
        function marker = getWriteableMarker(obj,stream_name)
            module_name = 'MATLAB';
            marker = obj.info.getMarker(module_name,stream_name);
        end
        function marker = getMarker(obj,module_name,stream_name)
            marker = obj.info.getMarker(module_name,stream_name);
        end
        function chan = getChannel(obj,module_name,stream_name)
            chan = obj.info.getChan(module_name,stream_name);
        end
    end
end

