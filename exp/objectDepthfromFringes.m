function [dps,dmr, dfr] = objectDepthfromFringes(path, focus, fringeType, paras)
poses = length(focus);
pshift = paras.pshift; 
T = paras.mrT;
IoA = paras.IoA;
space = T;
imgHeight = paras.height;
imgWidth = paras.width;
iHeight =  IoA(2)-IoA(1)+2*space+1; 
iWidth =  IoA(4)-IoA(3)+2*space+1; 
 
modps = zeros(imgHeight, imgWidth, poses);
modfr = zeros(imgHeight, imgWidth, poses);
modmr = zeros(imgHeight, imgWidth, poses);
for i = 1:length(focus)
    fringes = cell(1, pshift);
    for j = 1: pshift
        if(fringeType==1)
            im_name = strcat(path,'im_', num2str(2*i), '_', num2str(j-1), '.bmp');
            im = double(imread(im_name));
            im_blur = imgaussfilt(im, 3.5);
            fringes{1, j} = im_blur(IoA(1)-space:IoA(2)+space, IoA(3)-space:IoA(4)+space); 
        else
            im_name = strcat(path,'im_', num2str(2*i-1), '_', num2str(j-1), '.bmp');
            im = double(imread(im_name));
            fringes{1, j} = im(IoA(1)-space:IoA(2)+space, IoA(3)-space:IoA(4)+space); 
        end
    end
    frmod = fourier_mod(fringes{1,pshift});
    modfr(IoA(1): IoA(2), IoA(3): IoA(4), i) = frmod(space+1: (IoA(2)-IoA(1)+space+1), space+1: (IoA(4)-IoA(3)+space+1));
    mrmod = moer_mod(fringes{1,pshift}, T);
    modmr(IoA(1): IoA(2), IoA(3): IoA(4), i) = mrmod(space+1: (IoA(2)-IoA(1)+space+1), space+1: (IoA(4)-IoA(3)+space+1));
    fringeGroup = fringes(1,1:pshift);
    reshapedFringes = reshape(cat(3, fringeGroup{:}), iHeight, iWidth, []);
    psmod= ps_mod(reshapedFringes);
    modps(IoA(1): IoA(2), IoA(3): IoA(4), i) = psmod(space+1: (IoA(2)-IoA(1)+space+1), space+1: (IoA(4)-IoA(3)+space+1));
end
dps = gaussFitwithCog(focus, modps);
dmr = gaussFitwithCog(focus, modmr);
dfr = gaussFitwithCog(focus, modfr);
end