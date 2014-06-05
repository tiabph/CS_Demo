function img_est = MolEst_eps(img_raw,len,A,c,eps)

b = img_raw(:);

n = len;

cvx_begin
    variable x(n)
    minimize(c*x)
    subject to
        x >= 0;
        norm( A * x - b, 2 )<=eps;
cvx_end

img_est = x;