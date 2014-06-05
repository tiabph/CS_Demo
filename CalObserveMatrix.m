function [A tlen IntMask] = CalObserveMatrix(img_xx,img_yy,img_zz,xx,yy,zz,m_par)
%calulate observe matrix A
%

%     [t_xx t_yy t_zz] = meshgrid((1:1/mag:img_width).*img_a, ...
%                             (1:1/mag:img_width).*img_a, ...
%                               ((1:mag_z)-mag_z/2).*(z_depth/mag_z));
    t_xx=xx(:);
    t_yy=yy(:);
    t_zz=zz(:);
    tlen = length(t_xx(:));  
    A = zeros(length(img_xx(:))*2, tlen+1);
    IntMask = zeros(1,tlen);
    for m=1:tlen
        timg = GenPSFStack(img_xx,img_yy,img_zz,t_xx(m),t_yy(m),t_zz(m),m_par);
        timg = [timg(:,:,1) timg(:,:,2)];
        A(:,m) = timg(:);
        IntMask(m) = sum(timg(:));
    end
    IntMask = IntMask./max(IntMask(:));
    
%     c = sum(A(:,tlen));
%     PSF_integ = max(c); % integration of the PSF over space, used for normalization
%     c = c./ PSF_integ; % normalize to 1
%     A = A./ PSF_integ;
    
    % add the extra optimization variable for the estimation of the background
    tlen = tlen + 1;
%     c(tlen) = 0;
    A(:,tlen) = 1;
    
%     A = sparse(A);
end