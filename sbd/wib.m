clear all

I = imread('~/Desktop/lucy.png');

map = [0   0   0  ;
       15  0   0  ;
       0   15  0  ;
       15  15  0  ;
       0   0   15 ;
       15  0   15 ;
       0   15  15 ;
       15  15  15 ;
       5   5   5  ;
       0   5   0  ;
       10  5   0  ;
       0   5   10 ;
       0   0   5  ;
       5   0   0  ;
       10  10  10 ;
       5   0   5  ];

I = double(I ./ (255 / 15));

SBD = zeros(size(I,1), size(I,2));

for i=1:size(I,1)
    for j=1:size(I,2)
        pix = squeeze(I(i,j,:))';
        pix = repmat(pix, 16, 1);
        d = sqrt(sum((pix - map).^2,2));
        [~,ind] = min(d);
        SBD(i,j) = ind;
    end
end


SBD2 = [];
for i=1:1:size(I,1)
    for j=1:4:size(I,2)
        b = bitshift(SBD(i, j:j+3), [12, 8, 4, 0]);
        b = bitor(b(1), bitor(b(2), bitor(b(3), b(4))));
        SBD2 = [ SBD2 ; b ];
    end
end