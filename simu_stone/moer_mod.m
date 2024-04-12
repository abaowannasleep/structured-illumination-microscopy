function [mod] = moer_mod(img, T)
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
        interpolatedData = fillmissing(tmp, 'linear', 2, 'EndValues', 'none');
        imgs(:, :, t) = reshape(interpolatedData, height, width);
    end
    mod = ps_mod(imgs);
end

% function [mod] = moer_mod(img, T)
%     [height, width] = size(img);
%     imgs = zeros(height, width, T);
%     sample_num = floor(width/T)-1;
%     
%     parfor t = 1:T
%         indices = t + T * (0:sample_num);
%         imgs(:, indices, t) = img(:, indices);
%     end
%     
%     imgs(imgs == 0) = NaN; % Replace zeros with NaN in the entire imgs array
%     
%     parfor t = 1:T
%         tmp = reshape(imgs(:, :, t), height, []);
%         interpolatedData = fillmissing(tmp, 'linear', 2, 'EndValues', 'none');
%         imgs(:, :, t) = reshape(interpolatedData, height, width);
%     end
%     
%     mod = ps_mod(imgs, T);
% end