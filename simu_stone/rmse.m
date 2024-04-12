function [rms_err] = rmse(mat1,mat2,mask)
%SSE 此处显示有关此函数的摘要
%   此处显示详细说明
err = sum(((mat1-mat2).*mask).^2,  'ALL')/(sum(sum(mask)));
rms_err = sqrt(err);
end

