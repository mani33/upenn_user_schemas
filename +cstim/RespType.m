%{
cstim.RespType (manual) # is it fepsp slope or popspike?
->cont.Chan
slope = 0: boolean  # slope type?
popspike = 0: boolean # is it popspike?
---

%}

classdef RespType < dj.Relvar
    properties(Constant)
        table = dj.Table('cstim.RespType');
    end
    
    methods
        function self = RespType(varargin)
            self.restrict(varargin{:})
        end
    end
end