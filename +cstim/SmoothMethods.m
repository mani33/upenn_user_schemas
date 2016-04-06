%{
cstim.SmoothMethods (lookup) # my newest table
smooth_method_num: smallint unsigned # smoothing method number
-----
smooth_method_name: varchar(256) # smoothing method name
filter_params: blob # parameters of the filter

%}

classdef SmoothMethods < dj.Relvar
        properties(Constant)
        table = dj.Table('cstim.SmoothMethods');
    end
    
    methods
        function self = SmoothMethods(varargin)
            self.restrict(varargin{:})
        end
    end
end