function I = nature_image_resize(image, sz, aug, model)
    if nargin < 4
        model = false;
        if nargin < 3
            aug = 0;
        end
    end
    if size(image,3)==1
        image = cat(3,image,image,image);
    elseif size(image,3)>1
        image = image(:,:,1:3);
    end
    if isa(image, 'uint16')
        image=uint8(255*single(image)/65535);
%     elseif isa(image, 'single') || isa(image, 'double')
%         image=uint8(255*image);
    end
    image = imresize(image,[257,257],'bilinear');
    I = image(15*mod(aug+4,3)+(1:sz),15*floor((aug+4)/3)+(1:sz),:);
    if isa(model,'struct')
        im = 1-edgesDetect(I,model);
        im = ~im2bw( im, 0.8 );
        I = uint8(~bwmorph(im, 'thin', inf)*255);
    end
end