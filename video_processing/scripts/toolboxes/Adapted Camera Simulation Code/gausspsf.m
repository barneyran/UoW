% Code from R. Jenkin - Supplied alongside airy_disc.m file.

function matrix = gausspsf(matrix, sigma, center)
        gsize = size(matrix);
        for r=1:gsize(1)
            for c=1:gsize(2)
                matrix(r,c) = gaussC(r,c, sigma, center);
            end
        end
        
end

function val = gaussC(x, y, sigma, center)
    xc = center(1);
    yc = center(2);
    %exponent = ((x-xc).^2 + (y-yc).^2)./(2*sigma);
    %val       = (exp(-exponent)); 

    exponent = ((x-xc).^2 + (y-yc).^2)./(2*sigma^2);
    amplitude = 1 / (2 * sqrt(2*pi));  
    % The above is very much different than Alan's "1./2*pi*sigma^2"
    % which is the same as pi*Sigma^2 / 2.
    val       = amplitude  * exp(-exponent);
end
        
        