function [result timeelapse] = CSSTORM3D(img1, img2, mag, zmag, zdepth, Tol, debug,m_par)
    
%     mag = 16;
    mag_z = zmag;
    z_depth = zdepth;
%     m_par = MakePar(0.24,-0.25,0.25,0.5,1.8,0.89);
    threshold = 10;
 
    %% create grid
    %low-res image meshgrid
    img_size = size(img1);
    img_width = img_size(1);
    img_margin = 1;
    img_a = 0.1;
    [img_xx img_yy img_zz] = meshgrid((0.5:img_width).*img_a,(0.5:img_width).*img_a,0);
    
    %low-res box meshgrid
    box_width = 8;
    box_overlap = 4;
    [box_xx box_yy box_zz] = meshgrid((0.5:box_width).*img_a,(0.5:box_width).*img_a,0);

    
    result_width = img_width*mag;
    result_depth = mag_z;
    result_size = [result_width result_width result_depth];

    %high-res box meshgrid
    [t_xx t_yy t_zz] = meshgrid((1/mag/2:1/mag:box_width).*img_a, ...
                                (1/mag/2:1/mag:box_width).*img_a, ...
                                  linspace(-z_depth,z_depth,mag_z));
    t_size = size(t_xx);
    t_len = t_size(1)*t_size(2)*t_size(3);
    %observation matrix
    [A om_len intmask] =  CalObserveMatrix(box_xx,box_yy,box_zz,t_xx,t_yy,t_zz,m_par);
    c=sum(A);
    c(end)=0;
    mc=max(c(:));
    
    %high-res image meshgrid
    [result_xx result_yy result_zz] = meshgrid((1/mag/2:1/mag:img_width).*img_a, ...
                                (1/mag/2:1/mag:img_width).*img_a, ...
                                  linspace(-z_depth,z_depth,mag_z));
    
    result = zeros(size(result_xx));
    
    tilemaske = CreateTileMask(box_width, mag);
    %% process
    timestamp = cputime;
    CurrentImg1 = img1;
    CurrentImg2 = img2;
    for CurrentX = 1: box_width-box_overlap: img_width-box_width+1
        for CurrentY = 1: box_width-box_overlap: img_width-box_width+1
            %raw image rect
            raw_xs = CurrentX;
            raw_xe = raw_xs+box_width-1;
            raw_ys = CurrentY;
            raw_ye = raw_ys+box_width-1;
            %result image rect
            res_xs = (CurrentX-1)*mag+1;
            res_xe = res_xs+box_width*mag-1;
            res_ys = (CurrentY-1)*mag+1;
            res_ye = res_ys+box_width*mag-1;
            %result coordinate
            grid_xs = result_xx(res_ys,res_xs,1)-t_xx(1,1,1);
            grid_ys = result_yy(res_ys,res_xs,1)-t_yy(1,1,1);
            grid_zs = result_zz(res_ys,res_xs,1)-t_zz(1,1,1);
            
            %sub image
            subimg1 = CurrentImg1(raw_ys:raw_ye,raw_xs:raw_xe);
            subimg2 = CurrentImg2(raw_ys:raw_ye,raw_xs:raw_xe);
            subimg = [subimg1 subimg2];
            
            %reconstruct
%             subresult = SolveBP(A, subimg(:), om_len,1000,100,1);%norm(subimg(:),2).*2e-3);
%             subresult = SolveLasso(A, subimg(:), om_len, 'nnlasso', 100, 1, 10);
            L1sum = norm(subimg(:),1);
            L2sum=sqrt(L1sum);
            subresult = MolEst_eps(subimg(:),om_len,A,c,L2sum*Tol);
            
            subresult(isnan(subresult))=0;
            subresult(subresult<0)=0;
            subresult_bkg = subresult(end);
            subresult = reshape(subresult(1:end-1),t_size);
            %----------- apply mask to the result image -------------%
%             subresult(1:mag,:,:)=0;
%             subresult(:,1:mag,:)=0;
%             subresult(end-mag+1:end,:,:)=0;
%             subresult(:,end-mag+1:end,:)=0;
            for tempcnt = 1:t_size(3)
                subresult(:,:,tempcnt) =  subresult(:,:,tempcnt).*tilemaske;
            end
%             subresult(1:mag*2,:,:)=0;
%             subresult(:,1:mag*2,:)=0;
%             subresult(end-mag*2+1:end,:,:)=0;
%             subresult(:,end-mag*2+1:end,:)=0;
%             result_img = sum(result,3);
            result(res_ys:res_ye,res_xs:res_xe,:) = result(res_ys:res_ye,res_xs:res_xe,:) + subresult;
            
            %remove result from low-res img
            [sub_tindex] = find(subresult>threshold);
            [sub_ta sub_tb sub_tc] = ind2sub(size(subresult), sub_tindex);
            subresult_contributelen = length(sub_tindex);
            subresult_x = zeros(1,subresult_contributelen);
            subresult_y = zeros(1,subresult_contributelen);
            subresult_z = zeros(1,subresult_contributelen);
            subresult_i = zeros(1,subresult_contributelen);
            for m=1:subresult_contributelen
                subresult_x(m) = t_xx(sub_ta(m),sub_tb(m),sub_tc(m))+grid_xs;
                subresult_y(m) = t_yy(sub_ta(m),sub_tb(m),sub_tc(m))+grid_ys;
                subresult_z(m) = t_zz(sub_ta(m),sub_tb(m),sub_tc(m))+grid_zs;
                subresult_i(m) = subresult(sub_ta(m),sub_tb(m),sub_tc(m));
            end
            tempimg1 = zeros(img_size);
            tempimg2 = zeros(img_size);
            for m=1:subresult_contributelen
                timg = GenPSFStack(img_xx,img_yy,img_zz,subresult_x(m),subresult_y(m),subresult_z(m),m_par);
                tempimg1 = tempimg1 + timg(:,:,1).*subresult_i(m);
                tempimg2 = tempimg2 + timg(:,:,2).*subresult_i(m);
            end
            CurrentImg1 = CurrentImg1 - tempimg1;
            CurrentImg2 = CurrentImg2 - tempimg2;
            if(debug>0)
                figure(1)
                imagesc([CurrentImg1 CurrentImg2]);
                drawnow
                
                figure(2)
                imagesc((sum(result,3)))
                drawnow
                
                figure(3)
                imagesc([tempimg1 tempimg2]);
                drawnow
            end
        end
    end
    
    timeelapse = cputime - timestamp;

end