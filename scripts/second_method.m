function second_method(n, i)
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
    disp("Created " + string(n) + " Matrices in " + string(toc) + " seconds. (without class but second file, " + endstring)
end