%Authors---- zhang xiaohong
%Creating time----2006.12

function corner = DoGDetector(varargin)

[I,threshold,sig,Near,H,L,Gap_size] = parse_inputs(varargin{:});


%Find the edge of image

BW=EDGE(I,'canny',[L,H]);  % Detect edges,  don't use 2  ***

%Find the coordinates of curves
[curve,curve_start,curve_end,curve_mode,curve_num]=extract_curve(BW,Gap_size);  

corner = [];
for j = 1:size(curve, 2)
    cur= curve{j};
    y=cur(:,2);
    x=cur(:,1);
    W= 30;
 
    %At the two ends of curve, extend the curve by asymmetric method, such
    %as, a sequence: 1 2 3 4 5 6 7 8 9, the extened sequence: 4 3 2 1 2 3 4 5 6 7 8 9 8 7 6
    L=length(x);
    if L>W
        % Calculate curvature
        if curve_mode(j,:) == 'loop'
            x1=[x(L-W+1:L);x;x(1:W)];
            y1=[y(L-W+1:L);y;y(1:W)];
        else
            x1=[ones(W,1)*2*x(1)-x(W+1:-1:2);x;ones(W,1)*2*x(L)-x(L-1:-1:L-W)];
            y1=[ones(W,1)*2*y(1)-y(W+1:-1:2);y;ones(W,1)*2*y(L)-y(L-1:-1:L-W)];
        end
   
    y = y1';
    x = x1';    

    %To do DoG operator
    dogfilter = DoGfilter(sig);
    dogx = convolution(x, dogfilter);
    dogy = convolution(y, dogfilter);

    %To calculate inner product of DoG
    P = dogx.*dogx + dogy.*dogy;

   %Find extremum of DoG
    extremum_index = zeros(1,size(cur,1));
    for i=W+1:L+W
        if sum(P(i)>P(i-Near:i+Near))==(Near*2)
            extremum_index(i-W)=1;  % In extremum, odd points is minima and even points is maxima
        end    
    end
    
    %Find index beyond the pre-threshold
    threshold_index = zeros(1,size(cur,1));
    threshold_index = (P(W+1:L+W)>threshold);
 
    %index is used for the detected corners
    corner_index = find((threshold_index & extremum_index)==1);
    
   %Record the corner
    temp = cur(corner_index', :);
    corner = [corner; temp]; 
end
end


% show corner

figure, imshow(~BW);
hold on
plot(corner(:, 2), corner(:, 1), 'r.');
hold off

function [filter, width] = DoGfilter(sigma)
     GaussianDieOff = .0001;
     pw = 1:50;  % possible widths
     
     ssq1 = sigma*sigma;
     sig2 = sigma-1;
     ssq2 = sig2*sig2;
     ssq = max(ssq1,ssq2);
     % 	width = max(find(exp(-(pw.*pw)/(2*ssq))>GaussianDieOff));
     width = find(exp(-(pw.*pw)/(2*ssq))>GaussianDieOff,1,'last');
     if isempty(width)
         width = 1;  
     end
     t = (-width:width);
     gau1 = exp(-(t.*t)/(2*ssq1))/(2*pi*ssq1); 
     gau2 = exp(-(t.*t)/(2*ssq2))/(2*pi*ssq2); 
     gau1=gau1/sum(gau1);
     gau2=gau2/sum(gau2);
     filter = gau2-gau1;
return

function [I,Threshold,Sig,Near,H,L,Gap_size] = parse_inputs(varargin);

error(nargchk(0,8,nargin));

Para=[0.08,3,1,0.35,0,1]; %Default experience value;

if nargin>=2
    I=varargin{1};
    for i=2:nargin
        if size(varargin{i},1)>0
            Para(i-1)=varargin{i};
        end
    end
end

if nargin==1
    I=varargin{1};
end
    
if nargin==0 | size(I,1)==0
    [fname,dire]=uigetfile('*.bmp;*.jpg;*.gif','Open the image to be detected');
    I=imread([dire,fname]);
end

Threshold=Para(1);
Sig=Para(2);
Near=Para(3);
H=Para(4);
L=Para(5);
Gap_size=Para(6);
return
