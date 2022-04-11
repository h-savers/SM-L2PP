
function y = computemode(x)
[c d]=size(x) ; 
aa=find(x == 210) ; 
[a b]=size(aa) ; 
if a<0.01*c 
    y = mode(x);
else
    y=uint8(210); 
end
end
