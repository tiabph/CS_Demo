function imgs = GenPSFStack(xx,yy,zz,x0,y0,z0,par)
%generate 3d psf images
    wx1 = GenWidthofPSF(z0(1)-zz(1),par.w0,par.cx1,par.d,par.ax,par.bx);
    wx2 = GenWidthofPSF(z0(1)-zz(1),par.w0,par.cx2,par.d,par.ax,par.bx);
    hx1 = GenHeightofPSF(z0(1)-zz(1),par.w0,par.cx1,par.d,par.ax,par.bx);
    hx2 = GenHeightofPSF(z0(1)-zz(1),par.w0,par.cx2,par.d,par.ax,par.bx);
%     wy = GenWidthofPSF(z0(1)-zz(1),par.w0,par.cy,par.d,par.ay,par.by);
    s=size(xx);
    imgs = zeros([s 2]);
    imgs(:,:,1) = GenDoubleGaussianPeak(xx,yy,x0,y0,wx1).*hx1;
    imgs(:,:,2) = GenDoubleGaussianPeak(xx,yy,x0,y0,wx2).*hx2;
    imgs = imgs./max(imgs(:));
end