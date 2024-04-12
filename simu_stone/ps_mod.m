function [mod] = ps_mod(patterns)
    [height, width, pshift] = size(patterns);
    sinsum = zeros(height, width);
    cossum = zeros(height, width);
    for i = 1:pshift
        sinsum = sinsum + patterns(:,:,i)*sin(2*pi*(i-1)/pshift+pi);
        cossum = cossum + patterns(:,:,i)*cos(2*pi*(i-1)/pshift+pi);
    end
    mod = sqrt((sinsum.*sinsum)+(cossum.*cossum));
end