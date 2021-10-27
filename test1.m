N = 64;
%BLK 1: read image
fid=fopen('D:\pic\charact1.txt');
If=char(10);
cr=char(13);
A=fscanf(fid,[cr If '%c'],[64,64]);
fclose(fid);
A=A';
img=zeros(64,64);
for i=1:size(img,1)
    for j=1:size(img,2)
        if A(i,j)>'0'
            img(i,j)=255;
        end
    end
end
%END BLK 1
%BLK 2: outline
for i=1 : N-1   %so that the subscripts will not go beyond the boundary
    for j=1 : N-1
        if(img(i, j) * img(i + 1, j) == 0 && img(i, j) + img(i + 1, j) ~= 0)
            if(img(i, j) == 0)
                outline(i, j) = 255;
            else
                outline(i + 1, j) = 255;
            end
        end
        if(img(i, j) * img(i, j + 1) == 0 && img(i, j) + img(i, j + 1) ~= 0)
            if(img(i, j) == 0)
                outline(i, j) = 255;
            else
                outline(i, j + 1) = 255;
            end
        end
    end
end
%END BLK 2
global seg;
global visited;
seg = zeros(N,N);
visited = zeros(N,N);
outline = zeros(N,N);
nSeg = 0;
%BLK 3: segmentation
for i = 1 : N
    for j = 1 : N
        if(img(i, j) >0)
            temp = segNum(seg, i, j);
            if(temp ~= 0)
                seg(i, j) = temp;
            else
                seg(i, j) = nSeg + 1;
                nSeg = nSeg + 1;
            end
        end
    end
end

for i = 1 : N
    for j = 1 : N
        if(seg(i, j) > 0 && ~visited(i, j))
            segMerge(i, j, seg(i, j));
        end
    end
end
%END BLK 3
%BLK 4: segments numbering
segCountTemp = zeros(nSeg);
for i = 1 : N
    for j = 1 : N
        if(seg(i, j) > 0)
            segCountTemp(seg(i, j)) = segCountTemp(seg(i, j)) + 1;
        end
    end
end
segCount = zeros(nSeg);
updateSegNum = zeros(nSeg);
n = 0;
for i = 1 : nSeg
    if(segCountTemp(i) > 0)
        n = n + 1;
        segCount(n) = segCountTemp(i);
        updateSegNum(i) = n;
    end
end
nSeg = n;
for i = 1 : N
    for j = 1 : N
        if(seg(i, j) > 0)
            seg(i, j) = updateSegNum(seg(i, j));
        end
    end
end
%END BLK 4
%BLK 5: find rectangular boundaries
vertices = zeros(6, 2, 2);  %middle: 1: min, 2: max
for i = 1 : nSeg 
    vertices(i, 1, 1) = N - 1;
    vertices(i, 1, 2) = N - 1;
end
for i = 1 : nSeg    %determine vertices of the rectangles
    for j = 1 : nSeg
        if(seg(i, j) > 0)
            if(vertices(i, 1, 1) > j)
                vertices(i, 1, 1) = j;
            end
            if(vertices(i, 1, 2) > i)
                vertices(i, 1, 2) = i;
            end
            if(vertices(i, 2, 1) < j)
                vertices(i, 2, 1) = j;
            end
            if(vertices(i, 2, 2) < i)
                vertices(i, 2, 2) = i;
            end
        end
    end
end
%END BLK 5

XX=rotate();
imshow(XX);
