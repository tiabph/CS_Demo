function result = CreateTileMask(tilesize, mag)
    result = ones(tilesize*mag, tilesize*mag);
    for m=1:mag
        result((mag+m):(end-mag-m+1),mag+m)=m/mag;
        result((mag+m):(end-mag-m+1),end-mag+1-m)=m/mag;
        result(mag+m,(mag+m):(end-mag-m+1))=m/mag;
        result(end-mag+1-m,(mag+m):(end-mag-m+1))=m/mag;
    end
    result(:,1:mag)=0;
    result(:,(end-mag+1):end)=0;
    result(1:mag,:)=0;
    result((end-mag+1):end,:)=0;
end