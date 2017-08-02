%{
beh.MotionDetIgnore(manual) # session where motion tracking failed
-> acq.Sessions
-----
%}

classdef MotionDetIgnore < dj.Relvar
    
    properties(Constant)
        table = dj.Table('beh.MotionDetIgnore')       
    end
    
    methods
        function self = MotionDetIgnore(varargin)
            self.restrict(varargin{:})
        end
    end
end