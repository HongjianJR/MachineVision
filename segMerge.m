
function segMerge(i, j, mergeTo)
    global seg;
    global visited;
    visited(i, j) = 1;
    seg(i, j) = mergeTo;
    if(seg(i+1, j) ~= 0 && visited(i+1, j) == 0)
        segMerge( i + 1, j, mergeTo);
    end
    if(seg(i-1, j) ~= 0 && visited(i-1, j) == 0)
        segMerge( i - 1, j, mergeTo);
    end
    if(seg(i, j+1) ~= 0 && visited(i, j+1) == 0)
        segMerge( i, j+1, mergeTo);
    end
    if(seg(i, j-1) ~= 0 && visited(i, j-1) == 0)
        segMerge(i, j-1, mergeTo);
    end
end