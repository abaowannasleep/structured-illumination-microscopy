objPath1 = '.\images\plane\1mm-1-0.04-2.72\';
focus1 = (1: 0.04: 2.72);
poses = length(focus1);
objPath2 =   '.\images\plane\2mm-3.72-0.04-2\';
focus2 = (3.72: -0.04: 2);
pshift = 5;
IoA =  [200, 1200, 200, 1800];
paras = struct('pshift', pshift, 'IoA', IoA);
[bdepth1, bintensities1, bmodps1, bmods1] = depthfromFringes(objPath1, 1, focus1, paras);
[bdepth2, bintensities2, bmodps2, bmods2] = depthfromFringes(objPath2, 1, focus2, paras);
bdepth = bdepth2 - bdepth1;
[sdepth1, sintensities1, smodps1, smods1] = depthfromFringes(objPath1, 0, focus1, paras);
[sdepth2, sintensities2, smodps2, smods2] = depthfromFringes(objPath2, 0, focus2, paras);
sdepth = sdepth2 - sdepth1;
sintensities = sintensities1 + sintensities2;
bintensities = bintensities1 + bintensities2;
smods = smods1 + smods2;
bmods = bmods1 + bmods2;
%%
var(bdepth, 1, 'all')
var(sdepth, 1, 'all')
rmse(bdepth, 1, 1)
rmse(sdepth, 1, 1)
%%
t1 = reshape(smodps1(450, 320, :), [1, poses]);
t2 = reshape(bmodps1(450, 320,:), [1, poses]);
plot(mapminmax(t1, 0, 1), 'b--', Linewidth=2);
hold on;
plot(mapminmax(t2, 0, 0.95), 'r--', Linewidth=2);
hold off
ylim([0, 1.05]), xlim([1, 40]),
xlabel('x/step');ylabel('y/modulation');
title('(d)', 'FontName','Times New Roman','FontSize',18) 
legend('sinusoidal fringe)', 'binary encoded fringe');
set(gca,'FontSize',18);
%%
zmin = 0;
zmax = 1;
figure(3)
tiledlayout(1, 2);
ax1 = nexttile; mesh(abs(sdepth));  %zlim([zmin zmax]);
view(55, 30)
title('(a)', 'FontName','Times New Roman','FontSize',18)
xlabel('x/pixel');ylabel('y/pixel');zlabel('height/mm');xlim tight, ylim tight;
set(gca,'FontSize',16);
ax2 = nexttile; mesh(abs(bdepth));  %zlim([zmin zmax]);
view(55, 30)
title('(b)', 'FontName','Times New Roman','FontSize',18)
xlabel('x/pixel');ylabel('y/pixel');zlabel('height/mm');xlim tight, ylim tight;
set(gca,'FontSize',16);
cb = colorbar;
cb.Label.FontSize = 18;
%%
sfvi = zeros(1, poses-1);
bfvi = zeros(1, poses-1);
sfvm = zeros(1, poses-1);
bfvm = zeros(1, poses-1);

for i = 2:poses
    sfvi(i-1) = abs(sintensities(i) - sintensities(i-1))/0.02;
    bfvi(i-1) = abs(bintensities(i) - bintensities(i-1))/0.02;

    sfvm(i-1) = abs(smods(i) - smods(i-1))/abs(sintensities(i) - sintensities(i-1));
    bfvm(i-1) = abs(bmods(i) - bmods(i-1))/abs(bintensities(i) - bintensities(i-1));
end
deltai = bfvi-sfvi;
deltam = bfvm-sfvm;
figure(1)
plot(deltai(5:35), 'r:', Linewidth=3); hold on;
plot(deltam(5:35), 'b:', Linewidth=3); hold off;
xlabel('x/step'),ylabel('Difference of partial derivatives')
set(gca,'FontSize',18);
legend('\partial Ib/ \partial \delta z - \partial Is/ \partial \delta z ', '\partial Mb/ \partial Ib - \partial Ms/ \partial Is ');
title('(c)', 'FontName','Times New Roman','FontSize',18)
%%
% two stages validation 
% base
pshift = 5;
paras = struct('pshift', pshift, 'height', 1536, 'width', 2048, 'IoA', [200, 1200, 200, 1800], 'mrT', 64);
planePath =  '.\images\obj\plane1mm-2-0.02-1\';
focus_plane = (1: 0.02: 2);
[bdps, bdmr, bdfr] = objectDepthfromFringes(planePath, focus_plane, 1, paras);
[sdps, sdmr, sdfr] = objectDepthfromFringes(planePath, focus_plane, 0, paras);
%%
objPath1 =  '.\images\obj\stage2-1-0.05-3.4\';
focus1 = (-3.4: 0.05: -1);
[bdps1, bdmr1, bdfr1] = objectDepthfromFringes(objPath1, focus1, 1, paras);
[sdps1, sdmr1, sdfr1] = objectDepthfromFringes(objPath1, focus1, 0, paras);
%%
objPath2 =  '.\images\obj\stage1-0-0.05--3.4\';
focus2 = (-3.4: 0.05: 0);
[bdps2, bdmr2, bdfr2] = objectDepthfromFringes(objPath2, focus2, 1, paras);
[sdps2, sdmr2, sdfr2] = objectDepthfromFringes(objPath2, focus2, 0, paras);
%%
IoA = [200, 1200, 200, 1800];
mask = zeros(size(bdfr));
mask0 = double(imread('.\images\obj\stage2-1-0.05-3.4\mask.bmp'));
mask0(mask0>0) = 1;
mask0 = imbinarize(mask0);
mask(IoA(1):IoA(2), IoA(3):IoA(4)) = mask0;
%%
b1 = mask.*(bdps-bdps1);
b2 = mask.*(bdmr-bdmr1);
b3 = mask.*(bdfr-bdfr1);

s1 = mask.*(sdps-sdps1);
s2 = mask.*(sdmr-sdmr1); 
s3 = mask.*(sdfr-sdfr1);

stage = zeros(size(b1));
stage(b1>3.5) = 4.2;
stage(b1<3.5) = 3;
stage = stage.*mask;

rmse(stage, b1, mask)
rmse(stage, b2, mask)
rmse(stage, b3, mask)
rmse(stage, s1, mask)
rmse(stage, s2, mask)
rmse(stage, s3, mask)
%%
zmin = 2.95;
zmax = 4.25;
b1(b1==0)=nan;
b2(b2==0)=nan;
b3(b3==0)=nan;
figure(3)
tiledlayout(1, 3);
ax1 = nexttile; mesh(b1);  zlim([zmin zmax]); caxis([zmin zmax])
view(30, 45)
title('(a)', 'FontName','Times New Roman','FontSize',18)
xlabel('x/pixel');ylabel('y/pixel');zlabel('height/mm');xlim tight, ylim tight;
set(gca,'FontSize',18);
ax2 = nexttile; mesh(b2);  zlim([zmin zmax]); caxis([zmin zmax])
view(30, 45)
title('(b)', 'FontName','Times New Roman','FontSize',18)
xlabel('x/pixel');ylabel('y/pixel');zlabel('height/mm');xlim tight, ylim tight;
set(gca,'FontSize',18);
ax3 = nexttile; mesh(b3);  zlim([zmin zmax]); caxis([zmin zmax])
view(30, 45)
title('(c)', 'FontName','Times New Roman','FontSize',18)
xlabel('x/pixel');ylabel('y/pixel');zlabel('height/mm');xlim tight, ylim tight;
set(gca,'FontSize',18);
cb = colorbar;
cb.Label.FontSize = 18;
caxis('auto');
%%
s1(s1==0)=nan;
s2(s2==0)=nan;
s3(s3==0)=nan;
figure(4)
tiledlayout(1, 3);
ax4 = nexttile; mesh(s1);
view(30, 45)
title('(d)', 'FontName','Times New Roman','FontSize',18)
xlabel('x/pixel');ylabel('y/pixel');zlabel('height/mm');xlim tight, ylim tight;
set(gca,'FontSize',18);
ax5 = nexttile; mesh(s2); 
view(30, 45)
title('(e)', 'FontName','Times New Roman','FontSize',18)
xlabel('x/pixel');ylabel('y/pixel');zlabel('height/mm');xlim tight, ylim tight;
set(gca,'FontSize',18);
ax6 = nexttile; mesh(s3); 
view(30, 45)
title('(f)', 'FontName','Times New Roman','FontSize',18)
xlabel('x/pixel');ylabel('y/pixel');zlabel('height/mm');xlim tight, ylim tight;
set(gca,'FontSize',18);
cb = colorbar;
cb.Label.FontSize = 18;
caxis('auto');
%%
IoA = [200, 1200, 200, 1800];
mask2 = zeros(size(bdps));
mask0 = double(imread('.\images\obj\stage1-0-0.05--3.4\mask.bmp'));
mask0(mask0>0) = 1;
mask0 = imbinarize(mask0);
mask2(IoA(1):IoA(2), IoA(3):IoA(4)) = mask0;
%%
b21 = mask2.*(bdps-bdps2);
b22 = mask2.*(bdmr-bdmr2);
b23 = mask2.*(bdfr-bdfr2);

s21 = mask2.*(sdps-sdps2);
s22 = mask2.*(sdmr-sdmr2); 
s23 = mask2.*(sdfr-sdfr2);

stage2 = zeros(size(b21));
stage2(b21>4) = 4.2;
stage2(b21<2.8) = 2;
stage2(b21>2.8&b21<3.2) = 3;
stage2 = stage2.*mask2;

rmse(stage2, b21, mask2)
rmse(stage2, b22, mask2)
rmse(stage2, b23, mask2)
rmse(stage2, s21, mask2)
rmse(stage2, s22, mask2)
rmse(stage2, s23, mask2)
%%
zmin = 1.5;
zmax = 4.5;
b21(b21==0)=nan;
b22(b22==0)=nan;
b23(b23==0)=nan;
figure(3)
tiledlayout(1, 3);
ax1 = nexttile; mesh(b21);  zlim([zmin zmax]); caxis([zmin zmax])
view(40, 45)
title('(a)', 'FontName','Times New Roman','FontSize',18)
xlabel('x/pixel');ylabel('y/pixel');zlabel('height/mm');xlim tight, ylim tight;
set(gca,'FontSize',18);
ax2 = nexttile; mesh(b22);  zlim([zmin zmax]); caxis([zmin zmax])
view(40, 45)
title('(b)', 'FontName','Times New Roman','FontSize',18)
xlabel('x/pixel');ylabel('y/pixel');zlabel('height/mm');xlim tight, ylim tight;
set(gca,'FontSize',18);
ax3 = nexttile; mesh(b23);  zlim([zmin zmax]); caxis([zmin zmax])
view(40, 45)
title('(c)', 'FontName','Times New Roman','FontSize',18)
xlabel('x/pixel');ylabel('y/pixel');zlabel('height/mm');xlim tight, ylim tight;
set(gca,'FontSize',18);
cb = colorbar;
cb.Label.FontSize = 18;
caxis('auto');
%%
s21(s21==0)=nan;
s22(s22==0)=nan;
s23(s23==0)=nan;
figure(4)
tiledlayout(1, 3);
ax4 = nexttile; mesh(s21);  zlim([zmin zmax]);  caxis([zmin zmax])
view(40, 45)
title('(d)', 'FontName','Times New Roman','FontSize',18)
xlabel('x/pixel');ylabel('y/pixel');zlabel('height/mm');xlim tight, ylim tight;
set(gca,'FontSize',18);
ax5 = nexttile; mesh(s22);  zlim([zmin zmax]); caxis([zmin zmax])
view(40, 45)
title('(e)', 'FontName','Times New Roman','FontSize',18)
xlabel('x/pixel');ylabel('y/pixel');zlabel('height/mm');xlim tight, ylim tight;
set(gca,'FontSize',18);
ax6 = nexttile; mesh(s23);  zlim([zmin zmax]); caxis([zmin zmax])
view(40, 45)
title('(f)', 'FontName','Times New Roman','FontSize',18)
xlabel('x/pixel');ylabel('y/pixel');zlabel('height/mm');xlim tight, ylim tight;
set(gca,'FontSize',18);
cb = colorbar;
cb.Label.FontSize = 18;
caxis('auto');
