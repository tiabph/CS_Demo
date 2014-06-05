function w = GenWidthofPSF(z,w0,c,d,a,b)
%generate with of psf for GenDoubleGaussianPeak
%input:
%z  : z position
%w0 : width in focus
%c  : common focal position
%d  : field depth
%a,b: coefficiency of higher order
%output:
%w  : width of psf
    w = w0.*sqrt(1+((z-c)/d).^2+a*((z-c)/d).^3+b*((z-c)/d).^4);
end