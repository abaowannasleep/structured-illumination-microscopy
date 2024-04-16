%%
% sinusoidal fringe
focus = (-0.1: 0.01: 0.3);
poses = length(focus);
pshift = 5; 
imgHeight = 600;
imgWidth = 600;

load('plane_fringes.mat');
modps = zeros(imgHeight, imgWidth, poses);
fringesum = zeros(imgHeight, imgWidth, poses);
intensities = zeros(1, poses);
mods = zeros(1, poses);
for i = 1:length(focus)
    for j = 1: pshift
        im = fringes{i, j};
        fringes{i, j} = im(201:800, 201:800); 
        fringesum(:,:, i) = fringesum(:, :, i) +  fringes{i, j};
    end
    fringeGroup = fringes(i,1:pshift);
    reshapedFringes = reshape(cat(3, fringeGroup{:}), imgHeight, imgWidth, []);
    modps(:, :, i) = ps_mod(reshapedFringes);
    intensities(1, i) = mean(fringesum(:, :, i)/pshift, 'all');
    mods(1, i) = mean(modps(:, :, i), 'all');   
end
zps_gauss = gaussFitwithCog(focus, modps);
%%
% binary fringe
load('plane_bfringes.mat');
fbmodps = zeros(imgHeight, imgWidth, poses);
bfringesum = zeros(imgHeight, imgWidth, poses);
bintensities = zeros(1, poses);
bmods = zeros(1, poses);
for i = 1:length(focus)
    for j = 1: pshift);
        im = bfringes{i, j};
        bfringes{i, j} = imgaussfilt(im(201:800, 201:800), 3.5); 
        bfringesum(:,:, i) = bfringesum(:, :, i) +  bfringes{i, j};
    end
    bfringeGroup = bfringes(i,1:pshift);
    reshapedFringes = reshape(cat(3, bfringeGroup{:}), imgHeight, imgWidth, []);
    fbmodps(:, :, i) = ps_mod(reshapedFringes);
    bintensities(1, i) = mean((bfringesum(:, :, i)/pshift), 'all');
    bmods(1, i) = mean(fbmodps(:, :, i), 'all');    
end
fbzps_gauss = gaussFitwithCog(focus, fbmodps);
%%
var(zps_gauss, 1, 'all')
var(fbzps_gauss, 1, 'all')
%%
figure(2)
zmin = 0.05;
zmax = 0.15;
tiledlayout(1, 2);
ax1 = nexttile; mesh(zps_gauss); zlim([zmin zmax]);xlim tight, ylim tight;
xlabel('x/pixel');ylabel('y/pixel');zlabel('height/mm');
set(gca,'FontSize',18);
title('(a)', 'FontName','Times New Roman','FontSize',18)
view(45, -10)
ax2 = nexttile; mesh(fbzps_gauss); zlim([zmin zmax]);xlim tight, ylim tight
xlabel('x/pixel');ylabel('y/pixel');zlabel('height/mm');
set(gca,'FontSize',18);
title('(b)', 'FontName','Times New Roman','FontSize',18)
view(45, -10)
cb = colorbar;
cb.Label.FontSize = 16;
caxis(ax1,[zmin zmax])
caxis(ax2,[zmin zmax])
%%
mods = reshape(modps(200, 300, :), [1, 41]);
bfmods = reshape(fbmodps(200, 300, :), [1, 41]);
plot(mapminmax(mods, 0, 1), 'b--', Linewidth=2.5); hold on
plot(mapminmax(bfmods, 0, 1), 'r--', Linewidth=2.5); hold off
xlim([1,40]),ylim([0,1.05])
xlabel('step'),ylabel('modulation')
set(gca,'FontSize',18);
legend('sinusoidal fringe)', 'binary encoded fringe');
title('(c)', 'FontName','Times New Roman','FontSize',18)
%%
fvi = zeros(1, poses-1);
bfvi = zeros(1, poses-1);
fvm = zeros(1, poses-1);
bfvm = zeros(1, poses-1);

for i = 2:poses
    fvi(i-1) = abs(intensities(i) - intensities(i-1))/0.01;
    bfvi(i-1) = abs(bintensities(i) - bintensities(i-1))/0.01;

    fvm(i-1) = abs(mods(i) - mods(i-1))/abs(intensities(i) - intensities(i-1));
    bfvm(i-1) = abs(bmods(i) - bmods(i-1))/abs(bintensities(i) - bintensities(i-1));
end
figure(1)
plot(bfvi-fvi, 'r:', Linewidth=2.5); hold on;
plot(bfvm-fvm, 'b:', Linewidth=2.5); hold off;
ylim([-10, 55]); % xlim([1,18]); % 
xlabel('focus'),ylabel('Difference of partial derivatives')
set(gca,'FontSize',18);
legend('\partial Ib/ \partial \delta z - \partial Is/ \partial \delta z ', '\partial Mb/ \partial Ib - \partial Ms/ \partial Is ');
title('(d)', 'FontName','Times New Roman','FontSize',18)