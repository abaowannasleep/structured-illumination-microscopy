function [depth, intensities, modps, mods] = depthfromFringes(path, fringeType, focus, paras)
poses = length(focus);
pshift = paras.pshift; 
IoA = paras.IoA;
imgHeight = IoA(2)-IoA(1)+1;
imgWidth = (IoA(4)-IoA(3)+1);

modps = zeros(imgHeight, imgWidth, poses);
fringesum = zeros(imgHeight, imgWidth, poses);
intensities = zeros(1, poses);
mods = zeros(1, poses);
for i = 1:length(focus)
    fringes = zeros(imgHeight, imgWidth, pshift); 
    for j = 1: pshift
        if(fringeType==1)
            im_name = strcat(path,'im_', num2str(2*i), '_', num2str(j-1), '.bmp');
            im = double(imread(im_name));
            im_blur = imgaussfilt(im, 3.5);
            fringes(:,:, j) = im_blur(IoA(1):IoA(2), IoA(3):IoA(4)); 
            fringesum(:,:, i) = fringesum(:, :, i) +  fringes(:, :, j);
        else
            im_name = strcat(path,'im_', num2str(2*i-1), '_', num2str(j-1), '.bmp');
            im = double(imread(im_name));
            fringes(:,:, j) = im(IoA(1):IoA(2), IoA(3):IoA(4)); 
            fringesum(:,:, i) = fringesum(:, :, i) +  fringes(:, :, j);
        end
    end
    modps(:, :, i) = ps_mod(fringes);
    intensities(1, i) = mean(fringesum(:, :, i), 'all');
    mods(1, i) = mean(modps(:, :, i), 'all'); 
end
depth = gaussFitwithCog(focus, modps);
end