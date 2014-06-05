%% test Compreesed Sensing STORM
%start dip
dipstart

img_width = 16;
img_a = 0.1;
[img_xx img_yy img_zz] = meshgrid((0.5:img_width).*img_a,(0.5:img_width).*img_a,0);

mag = 8;
mag_z = 16;
z_depth = 0.2;

m_num = 10;
m_x = zeros(1,m_num);
m_y = zeros(1,m_num);
m_z = zeros(1,m_num);
for m=1:m_num
    m_x(1,m) = (rand().*(img_width-4)+2).*img_a;
    m_y(1,m) = (rand().*(img_width-4)+2).*img_a;
    m_z(1,m) = (rand()-0.5).*z_depth;
end

m_par = MakePar(0.2,-0.25,0.25,0.5,0,0);

%% Gen image

img =zeros(img_width,img_width,2);
for m=1:m_num
    timg = GenPSFStack(img_xx,img_yy,img_zz,m_x(m),m_y(m),m_z(m),m_par);
    img = img + timg;
end
imglen = length(img(:));

% dipstart
img = img.*1000;
I=img;
I=noise(I,'poisson',0.1);
I=dip_array(I);
I=I+150;
I=noise(I,'gaussian',20);
I=dip_array(I);
img=I;

% img = awgn(img);


%% CS reconstruct

[t_xx t_yy t_zz] = meshgrid((1/mag/2:1/mag:img_width).*img_a, ...
                                (1/mag/2:1/mag:img_width).*img_a, ...
                                  linspace(-z_depth,z_depth,mag_z));
ts =size(t_xx);

tlen = length(t_xx(:));  

[rawresult timeelapse] = CSSTORM3D(img(:,:,1), img(:,:,2), mag, mag_z, z_depth, 5,0,m_par);
rawresult(rawresult<0)=0;

result = rawresult;

%% display

figure(1)
imagesc([img(:,:,1) img(:,:,2)])
colormap gray

figure(2)
imagesc(sum(result,3))
hold on
plot((m_x./img_a)*mag+1,(m_y./img_a)*mag+1,'ro');
plot((img_xx./img_a)*mag+1,(img_yy./img_a)*mag+1,'b+');
hold off
colormap gray