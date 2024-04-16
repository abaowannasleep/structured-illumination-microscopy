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