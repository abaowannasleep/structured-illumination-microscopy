function [mod] = fourier_mod(fringe)
%     F = fftshift(fft2(img));
%     rect_window_filter = zeros(size(F));
%     r = [532, 495, 15, 15];
%     rect_window_filter(r(2):r(4)+r(2), r(1):r(3)+r(1)) = 1;
%     Q = rect_window_filter.*F;
%     s = ifft2(ifftshift(Q));
%     mod = 2*abs(s)/mean(img, 'ALL');
% 计算傅里叶变换
fringe_fft = fft2(double(fringe));
fringe_ffs = fftshift(fringe_fft);

[M, N] = size(fringe_fft);

% 设置高斯窗滤波器的大小和标准差 改成動態
w = [35,30,30, 30];     % 窗口大小
sigma = 30; % 标准差 调准标准差？
% % 找到频谱图的的一阶点
amplitude_spectrum = abs(fringe_ffs);% 使用fliter_img 来进行找点过程

num_points = 3 ;% 想要找到的最大的五个点
max_points = zeros(num_points,2);
for num = 1:num_points
    [~,max_index] = max(amplitude_spectrum(:));
    [row,col] = ind2sub(size(amplitude_spectrum),max_index);
    max_points(num,:)=[row,col];
    xy_range = (-floor(w(num)/2): floor(w(num)/2));
    windowx = row+xy_range; windowx(windowx<1)=1;windowx(windowx>M)=M;
    windowy = col+xy_range; windowy(windowy<1)=1;windowy(windowy>N)=N;
    amplitude_spectrum(windowx,windowy)=0;
end
peak = max_points(2, :);
num = 4;
% 生成高斯窗滤波器
[x, y] = meshgrid(1:N, 1:M);
gauss_mask = exp(-((x-peak(1,2)).^2 + (y-peak(1,1)).^2) ./ (2*sigma^2));
gauss_mask = gauss_mask .* (abs(x-peak(1,2))<=w(num)/2) .* (abs(y-peak(1,1))<=w(num)/2);

filtered_ffs = fringe_ffs .* gauss_mask;
fringe_filtered = ifft2(ifftshift(filtered_ffs));
mod = 2*abs(fringe_filtered)/mean(fringe, 'ALL');
% maskh = zeros(M, N); maskv = zeros(M, N);
% window = (-floor(w(num)/2): floor(w(num)/2));
% windowhx = peakh(1)+window;windowhx(windowhx<1)=1;windowhx(windowhx>M)=M;
% windowhy = peakh(2)+window;windowhy(windowhy<1)=1;windowhy(windowhy>N)=N; 
% maskh(windowhx,windowhy) = 1;
% windowvx = peakv(1)+window;windowvx(windowvx<1)=1;windowvx(windowvx>M)=M;
% windowvy = peakv(2)+window;windowvy(windowvy<1)=1;windowvy(windowvy>N)=N;
% maskv(windowvx,windowvy) = 1;
end