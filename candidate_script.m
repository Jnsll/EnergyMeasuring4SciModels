function candidate_script(n, mode)
    if ~exist("n",'var')
        n = 1200;
        disp("No maximum n given, we choose " + string(n) + " ...")
    end
    if ~exist("mode", 'var') || ~(mode == 0 || mode == 1)
        minimum = 0;
        maximum = 1;
        disp("No mode (preallocation/no preallocation) specified, or not in [0,1], we perform for both modes ...")
    else
        minimum = mode;
        maximum = mode;
    end
    for i = minimum:maximum
        method1(n, i);
        method2(n, i);
        method3(n, i);
    end
end

function method1(n, i)
    tic
    if i
        my_list = {};
        for i = 1:n
            my_list{end + 1} = My(i, i);
        end
        endstring = "without preallocation)";
    else
        my_list = cell(n, 1);
        for i = 1:n
            my_list{i} = My(i, i);
        end
        endstring = "with preallocation)";
    end
    disp("Created " + string(n) + " Matrices in " + string(toc) + " seconds. (via a class " + endstring)
end

function method2(n, i)
    second_method(n, i)
end

function method3(n, i)
    tic
    if i
        my_list = {};
        for i = 1:n
            my_list{end + 1} = ones(n, n) * n;
        end
        endstring = "without preallocation)";
    else
        my_list = cell(n, 1);
        for i = 1:n
            my_list{i} = ones(n, n) * n;
        end
        endstring = "with preallocation)";
    end
    disp("Created " + string(n) + " Matrices in " + string(toc) + " seconds. (without class in same file, " + endstring)
end