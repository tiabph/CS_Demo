function img = GenDoubleGaussianPeak(x_inx,y_inx,x_pos,y_pos,w_x)
    img = exp(-2*(((x_inx-x_pos)./w_x).^2+((y_inx-y_pos)./w_x).^2));
end