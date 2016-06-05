function I = edge_preserving_resize(sketch, sz, aug, edgeThin)
    rotateAngle = aug * 11.25;
    if nargin < 4
        edgeThin = false;
        if nargin < 3
            rotateAngle = 0;
        end
    end
    bw=~sketch;%im2bw(sketch,0.5);
    bw = bwmorph(bw, 'thin', inf);
    [oy, ox] = find(bw>0);
    maxoy=max(oy);maxox=max(ox);minoy=min(oy);minox=min(ox);
    
    midy=(maxoy+minoy)/2;
    midx=(maxox+minox)/2;
    bw2=imrotate(bw(minoy:maxoy, minox:maxox), rotateAngle);% rotateAngle = 11.25*i
    bw2 = bwmorph(bw2, 'thin', inf);
    [oy2, ox2] = find(bw2>0);
    oy2=oy2-min(oy2)+1;
    ox2=ox2-min(ox2)+1;    
    maxoy2=max(oy2);maxox2=max(ox2);minoy2=min(oy2);minox2=min(ox2);
    len2=max((maxoy2-minoy2+1),(maxox2-minox2+1));
    if len2>length(sketch)
        oy2 = round( oy2/len2*length(sketch) );
        ox2 = round( ox2/len2*length(sketch) );
    end
    maxoy2=max(oy2);maxox2=max(ox2);minoy2=min(oy2);minox2=min(ox2);
    midy2=(maxoy2+minoy2)/2;
    midx2=(maxox2+minox2)/2;
    
    oy3=max(ceil( ((oy2-midy2)+midy) /size(sketch,1)*sz),1);
    ox3=max(ceil( ((ox2-midx2)+midx) /size(sketch,2)*sz),1);
    
   bw3=zeros(sz,sz); 
   xy=unique([oy3,ox3],'rows','stable');
    for n=1:length(xy)
        bw3(xy(n,1),xy(n,2))=1;
    end 
    if edgeThin
        bw3 = bwmorph(bw3, 'thin', inf);
    end
    I=uint8(~bw3(1:sz,1:sz)*255);
end