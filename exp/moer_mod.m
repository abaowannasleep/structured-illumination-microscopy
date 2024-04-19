function [mod] = moer_mod(img, T)
    img = img.';
    [height, width] = size(img);
    imgs = zeros(height, width, T);
    sample_num = floor(width/T)-1;
    
    for t = 1:T
        indices = t + T * (0:sample_num);
        imgs(:, indices, t) = img(:, indices);
    end 
    imgs(imgs == 0) = NaN;
    for t = 1:T
        tmp = reshape(imgs(:, :, t), height, []);        
        interpolatedData = fillmissing(tmp, 'linear', 2);
        imgs(:, :, t) = reshape(interpolatedData, height, width);
    end
    mod = ps_mod(imgs);
    mod = mod.';
end
% function [mod] = moer_mod(img, T)
% img = img.';
% [height, width] = size(img);
% imgs = zeros(height, width, T);
% sample_num = floor(width/T)-1;
% for t = 1:T
%     for j = 0: sample_num
%         imgs(:,t+T*j, t) = img(:, t+T*j);
%     end
% %     imwrite(mapminmax(imgs(:, :, t), 0.1, 0.9), [num2str(t), '.bmp']);
% end
% x = 1: width;
% patterns = zeros(width, height, T);
% for t = 1:T
%     for i = 1:height
%     tmp = imgs(i, :, t);
%     tmp(tmp == 0) = NaN;
%     interpolatedData = fillmissing(tmp,'linear','SamplePoints',x);
%     imgs(i, :, t) = interpolatedData;
%     end
%     img = imgs(:, :, t);
%     patterns(:, :, t) = img.';
% %     imwrite(mapminmax(imgs(:, :, t), 0.1, 0.9), ['i_', num2str(t), '.bmp']);
% end
% mod = ps_mod(patterns);
% end