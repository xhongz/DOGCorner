

function Z = Convolution(X,Filter)
   
   %Calculate the length of extension
   LenF = length(Filter);
   HalfLen = fix(LenF/2);
   [Height,Width] = size(X);
 
   Result = zeros(Height,Width);
   Exp1 = zeros(Height,HalfLen);
   Exp2 = Exp1;
   
   a = HalfLen +1;
   c = LenF-1;
   
   %At the two ends of a sequence,extend the sequence
   Exp1(:,HalfLen:-1:1) = X(:,2:HalfLen+1);
   Exp2(:,1:HalfLen) = X(:,Width-1:-1:Width-HalfLen);
   Y = [Exp1,X,Exp2];
   %Calculate the convolution
   for i = 1:Width
       Result(:,i) = Y(:,i:i+c)*Filter';
   end
 Z = Result;
 