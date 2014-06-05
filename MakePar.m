function parameter = MakePar(w0,cx1,cx2,d,ax,bx)
%w0: width in focus
%cx: focus position in x
%cy
%d : focus depth
%ax: higher order parameter
%ay
%bx
%by
    parameter.w0 = w0;
    parameter.cx1 = cx1;
    parameter.cx2 = cx2;
%     parameter.cy = cy;
    parameter.d = d;
    parameter.ax = ax;
%     parameter.ay = ay;
    parameter.bx = bx;
%     parameter.by = by;
end