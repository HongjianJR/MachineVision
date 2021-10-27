img = imread('D:\pic\charact2.bmp');
img = rgb2gray(img);
H = size(img, 1);
W = size(img, 2);
%BLK 1: opening operation
SE = strel('square', 11);
img = imopen(img, SE);
img = imbinarize(img, 92/255);
%END BLK 1

global seg;
global visited;
seg = zeros(H, W);
visited = zeros(H, W);
nSeg = 0;
%BLK 2: segmentation

for i = 1 : H
    for j = 1 : W
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

for i = 1 : H
    for j = 1 : W
        if(seg(i, j) > 0 && ~visited(i, j))
            segMerge(i, j, seg(i, j));
        end
    end
end
%END BLK 2

%BLK 3: count number of pixels for each segment
pixelCount = zeros(nSeg);
for i = 1 : H
    for j = 1 : W
        if(seg(i, j) > 0)
            pixelCount(seg(i, j)) = pixelCount(seg(i, j)) + 1;
        end
    end
end
%END BLK 3

%BLK 4: efface noise and rearrange segments
segCount = zeros(nSeg);
updateSegNum = zeros(nSeg);
n = 0;
for i = 1 : nSeg
    if(pixelCount(i) > 100)
        n = n + 1;
        segCount(n) = pixelCount(i);
        updateSegNum(i) = n;
    else
        updateSegNum(i) = 0;    %noise
    end
end
nSeg = n;

for i = 1 : H
    for j = 1 : W
        if(seg(i, j) > 0)
            seg(i, j) = updateSegNum(seg(i, j));
            if(seg(i, j) == 0)
                img(i, j) = 0;  %eliminate from the original image
            end
        end
    end
end
%END BLK 4

%BLK 5: outline
outline = zeros(H, W);
for i = 1 : H - 1   %so that the subscripts will not go beyond the boundary
    for j = 1 : W - 1
        if(img(i, j) * img(i + 1, j) == 0 && img(i, j) + img(i + 1, j) ~= 0)
            if(img(i, j) == 0)
                outline(i, j) = 1;
            else
                outline(i + 1, j) = 1;
            end
        end
        if(img(i, j) * img(i, j + 1) == 0 && img(i, j) + img(i, j + 1) ~= 0)
            if(img(i, j) == 0)
                outline(i, j) = 1;
            else
                outline(i, j + 1) = 1;
            end
        end
    end
end
%END BLK 5

%BLK 6: find rectangular boundaries
vertices = zeros(nSeg + 4, 2, 2);  %middle: 1: min, 2: max; last: 1: x, 2: y
for i = 1 : nSeg 
    vertices(i, 1, 1) = W;
    vertices(i, 1, 2) = H;
end
for i = 1 : H    %determine vertices of the rectangles
    for j = 1 : W
        if(seg(i, j) > 0)
            if(vertices(seg(i, j), 1, 1) > j)
                vertices(seg(i, j), 1, 1) = j;
            end
            if(vertices(seg(i, j), 1, 2) > i)
                vertices(seg(i, j), 1, 2) = i;
            end
            if(vertices(seg(i, j), 2, 1) < j)
                vertices(seg(i, j), 2, 1) = j;
            end
            if(vertices(seg(i, j), 2, 2) < i)
                vertices(seg(i, j), 2, 2) = i;
            end
        end
    end
end

for i = vertices(1, 1, 2) : vertices(1, 2, 2)
    for j = 380 : vertices(1, 2, 1)
        if(seg(i, j) > 0)
            seg(i, j) = nSeg + 1;
        end
    end
end
vertices(nSeg + 1, 1, 1) = 380;
vertices(nSeg + 1, 1, 2) = vertices(1, 1, 2);
vertices(nSeg + 1, 2, 1) = vertices(1, 2, 1);
vertices(nSeg + 1, 2, 2) = vertices(1, 2, 2);
vertices(1, 2, 1) = 379;
for i = vertices(3, 1, 2) : vertices(3, 2, 2)
    for j = 857 : vertices(3, 2, 1)
        if(seg(i, j) > 0)
            seg(i, j) = nSeg + 2;
        end
    end
end
vertices(nSeg + 2, 1, 1) = 857;
vertices(nSeg + 2, 1, 2) = vertices(3, 1, 2);
vertices(nSeg + 2, 2, 1) = vertices(3, 2, 1);
vertices(nSeg + 2, 2, 2) = vertices(3, 2, 2);
vertices(3, 2, 1) = 856;
for i = vertices(5, 1, 2) : vertices(5, 2, 2)
    for j = 593 : vertices(5, 2, 1)
        if(seg(i, j) > 0)
            seg(i, j) = nSeg + 3;
        end
    end
end
vertices(nSeg + 3, 1, 1) = 593;
vertices(nSeg + 3, 1, 2) = vertices(5, 1, 2);
vertices(nSeg + 3, 2, 1) = vertices(5, 2, 1);
vertices(nSeg + 3, 2, 2) = vertices(5, 2, 2);
vertices(5, 2, 1) = 592;
for i = vertices(6, 1, 2) : vertices(6, 2, 2)
    for j = 243 : vertices(6, 2, 1)
        if(seg(i, j) > 0)
            seg(i, j) = nSeg + 4;
        end
    end
end
vertices(nSeg + 4, 1, 1) = 243;
vertices(nSeg + 4, 1, 2) = vertices(6, 1, 2);
vertices(nSeg + 4, 2, 1) = vertices(6, 2, 1);
vertices(nSeg + 4, 2, 2) = vertices(6, 2, 2);
vertices(6, 2, 1) = 242;
nSeg = nSeg + 4;
%{
for i = 1 : nSeg        %draw the rectangles
   for y = vertices(i, 1, 2) - 1 : vertices(i, 2, 2) + 1
       img(y, vertices(i, 1, 1) - 1) = 1;
       img(y, vertices(i, 2, 1) + 1) = 1;
   end
   for x = vertices(i, 1, 1) - 1 : vertices(i, 2, 1) + 1
       img(vertices(i, 1, 2) - 1, x) = 1;
       img(vertices(i, 2, 2) + 1, x) = 1;
   end
end
%}
%END BLK 6

%BLK 7: Sort the rectangles
rects_t(nSeg) = RectBoundary;
for i = 1 : nSeg
    rects_t(i).minX = vertices(i, 1, 1);
    rects_t(i).minY = vertices(i, 1, 2);
    rects_t(i).maxX = vertices(i, 2, 1);
    rects_t(i).maxY = vertices(i, 2, 2);
end

Y = [round(H / 3), round(H * 2 / 3)];
counter = 0;
reEnum = zeros(nSeg);
for i = 1 : 2
    x = 1;
    while x < W
        if(seg(Y(i), x) > 0)
            counter = counter + 1;
            reEnum(seg(Y(i), x)) = counter;
            x = rects_t(seg(Y(i), x)).maxX + 1; 
        else
            x = x + 1;
        end
    end
end
%imshow(img);
for i = 1 : H    %determine vertices of the rectangles
    for j = 1 : W
        if(seg(i, j) > 0)
            seg(i, j) = reEnum(seg(i, j));
        end
    end
end

rects(nSeg) = RectBoundary;
new_W = 0;
new_H = 0;
for i = 1 : nSeg
    rects(reEnum(i)) = rects_t(i);
    new_W = new_W + rects_t(i).maxX - rects_t(i).minX + 1;
    if(rects_t(i).maxY - rects_t(i).minY > new_H)
        new_H = rects_t(i).maxY - rects_t(i).minY;
    end
end
%END BLK 7, all regions sorted, left -> right, up -> down

%BLK 8: Sorted characters
img_sequence = zeros(new_H, new_W);
new_x = 1;
for i = 1 : nSeg
    for x = rects(i).minX : rects(i).maxX
        new_y = 2;
        for y = rects(i).minY : rects(i).maxY
            img_sequence(new_y, new_x) = img(y, x);
            new_y = new_y + 1;
        end
        new_x = new_x + 1;
    end
end
%imshow(img_sequence);
%END BLK 8

%BLK 9: thinning
thinned_img = repmat(img, 1);
%{%
marked = ones(H, W);
done = false;
while(~done)
    done = true;
    for i = 2 : H - 1
        for j = 2 : W - 1
            if(thinned_img(i, j) > 0)
                marked(i, j) = step1(thinned_img, i, j);
            end
        end
    end
    for i = 2 : H - 1
        for j = 2 : W - 1
            if(thinned_img(i, j) > 0)
                if(marked(i, j) == 0)
                    thinned_img(i, j) = 0;
                    done = false;
                end
            end
        end
    end
    for i = 2 : H - 1
        for j = 2 : W - 1
            if(thinned_img(i, j) > 0)
                marked(i, j) = step2(thinned_img, i, j);
            end
        end
    end
    for i = 2 : H - 1
        for j = 2 : W - 1
            if(thinned_img(i, j) > 0)
                if(marked(i, j) == 0)
                    thinned_img(i, j) = 0;
                    done = false;
                end
            end
        end
    end
end
%END BLK 9
%}
%thinned_img = bwmorph(thinned_img, 'thin', Inf);
imshow(img);