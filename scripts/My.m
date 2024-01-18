classdef My
    properties
        matrix
    end

    methods
        function obj = My(m, n)
            obj.matrix = ones(m, n) * n;
        end
    end
end