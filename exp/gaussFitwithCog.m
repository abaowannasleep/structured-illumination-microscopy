function [depth] = gaussFitwithCog(x, y)
% Closed-form solution for Gaussian interpolation using 3 points
% Guss func： y = A*e^[- (x-u)^2 / (2*s^2)]
% Internal parameter:
STEP = 2;
[M,N,P] = size(y);
initialI = cog(y, x);
x_extended = repmat(reshape(x, [1, 1, P]), [M, N, 1]);
tmp = initialI <= x_extended;
I = zeros(M, N);
for i = 1:M
    for j = 1:N
       pos =  find(reshape(tmp(i, j, :), [1,P]), 1, 'first');
       if isempty(pos)
           I(i,j) = P;
       else
           I(i,j) = pos;
       end
    end
end
[IN,IM] = meshgrid(1:N,1:M);
Ic = I(:);
Ic(Ic<=STEP)=STEP+1;
Ic(Ic>=P-STEP)=P-STEP;
% （maxPos-STEP，maxPos+STEP）
Index1 = sub2ind([M,N,P], IM(:), IN(:), Ic-STEP);
Index2 = sub2ind([M,N,P], IM(:), IN(:), Ic);
Index3 = sub2ind([M,N,P], IM(:), IN(:), Ic+STEP);
x1 = reshape(x(Ic(:)-STEP),M,N);
x2 = reshape(x(Ic(:)),M,N);
x3 = reshape(x(Ic(:)+STEP),M,N);
y1 = reshape(log(y(Index1)),M,N);
y2 = reshape(log(y(Index2)),M,N);
y3 = reshape(log(y(Index3)),M,N);

c = ( (y1-y2).*(x2-x3)-(y2-y3).*(x1-x2) )./...
    ( (x1.^2-x2.^2).*(x2-x3)-(x2.^2-x3.^2).*(x1-x2) );
b = ( (y2-y3)-c.*(x2-x3).*(x2+x3) )./(x2-x3);
a = y1 - b.*x1 - c.*x1.^2;
s = sqrt(-1./(2*c));
u = b.*s.^2;
A = exp(a + u.^2./(2*s.^2));

mask = false(size(u));
deta = 4*(abs(x(2)-x(1)));
mask(abs(u-initialI) >= deta) = true;
mask(isnan(u))=true;
mask(u>=max(x))=true;
mask(u<=max(x))=true;
depth = u;
depth(mask)=initialI(mask);
 end

function zi = cog(fm, z)
[height, width, seq] = size(fm);
fmmax = max(fm, [], 3);
fmmin = min(fm, [], 3);
mask = ones(height, width, seq);
mask(fm<fmmin+2*(fmmax-fmmin)/3) = 0;
filfm = fm .* mask;
zmu = permute(z, [1, 3, 2]);
zi = sum(bsxfun(@times, filfm, zmu), 3)./sum(filfm, 3);
zi(isnan(zi)) = mean(z);
end