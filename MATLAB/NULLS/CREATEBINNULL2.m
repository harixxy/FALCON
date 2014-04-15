% CREATEBINNULL2.m
% Part of the FALCON (Framework of Adaptive ensembLes for the Comparison Of
% Nestedness) package: https://github.com/sjbeckett/FALCON
% Last updated: 27th March 2014

function[MEASURES] = CREATEBINNULL2(MATRIX,numbernulls,measures,binNull,sortVar) %%FF
%Fixed - Fixed sequential trial swap only. Using advice on trial-swapping
%from Miklos and Podani, 2004 and the number of trial swaps to perform from
%Gotelli and Ulrich, 2011. The first null model is found by performing
%30,000 trial swaps on the input matrix to escape oversampling the input
%matrix, subsequent null models are found by performing further trial swaps
%and sampling the matrix every 5,000 trial swaps.

%I Miklós, J Podani. 2004.
%Randomization of presence-absence matrices: comments and new algorithms
%Ecology 85(1): 86 – 92. (http://dx.doi.org/10.1890/03-0101)

%N Gotelli, W Ulrich. 2011.
%Over-reporting bias in null model analysis: A response to Fayle and
%Manica(2010)
%Ecological Modelling 222: 1337 - 1339. (http://dx.doi.org/10.1016/j.ecolmodel.2010.11.008)

MEASURES = zeros(length(measures),numbernulls); %To store measure answers.
[r,c]=size(MATRIX);
TEST=MATRIX;
sampleafterspinup = 5000;

%CHECK THAT SWAPS CAN OCCUR - OR ELSE NO POINT
CHECKSWAPS=0;

if r < c
    
    for row1 = 1:(r-1)
        for row2 = 2:r
            TESTrows= TEST(row1,:) - TEST(row2,:);
            if sum(TESTrows==-1)>0 && sum(TESTrows==1)>0
                CHECKSWAPS=1;%swaps possible
                break;
            end
        end
    end
    
else
    
     for col1 = 1:(c-1)
        for col2 = 2:c
            TESTcols= TEST(:,col1) - TEST(:,col2);
            if sum(TESTcols==-1)>0 && sum(TESTcols==1)>0
                CHECKSWAPS=1;%swaps possible
                break;
            end
        end
     end
     
end


%If no swaps possible all will have the same score and nestedness should be
%insignificant.

if CHECKSWAPS==0
    
     [TEST,~]=sortMATRIX(TEST,binNull,sortVar);
        
     %measure
        for ww=1:length(measures)
            MEASURES(ww,:) = measures{ww}(TEST);
        end
               
    
else %IF swaps are possible - need to find out!

ID1 = eye(2);
ID2 = ID1([2 1],[1 2]);



if r*c>30000
    numberofswapstoattempt=r*c;
else
    numberofswapstoattempt=30000;
end

%Spin up with 30,000 trial swaps.
    
    for b=1:numberofswapstoattempt

        %Pick random cols and rows.
        rows = randperm(r,2);
        cols = randperm(c,2);
        

	if (  ( sum(sum( TEST(rows,cols)==ID1 ))==4  ) || ( sum(sum( TEST(rows,cols)==ID2 ))==4) )
            TEST(rows,cols)=TEST(rows(end:-1:1),cols);
	end

       
    end
    
    %Measure first matrix.
     %sort
    [TEST,~]=sortMATRIX(TEST,binNull,sortVar);



     %measure
        for ww=1:length(measures)
            MEASURES(ww,1) = measures{ww}(TEST);
        end
     
    
    %subsequent nulls are created from sampling the null after extra trial
    %swaps.
    
    for cc = 2:numbernulls
        
     for b=1:sampleafterspinup

        %Pick random cols and rows.
        %Pick random cols and rows.
        rows = randperm(r,2);
        cols = randperm(c,2);
        

	if (  ( sum(sum( TEST(rows,cols)==ID1 ))==4  ) || ( sum(sum( TEST(rows,cols)==ID2 ))==4) )
            TEST(rows,cols)=TEST(rows(end:-1:1),cols);
	end


     end
     
     %sort
       [TEST,~]=sortMATRIX(TEST,binNull,sortVar);

     %measure
        for ww=1:length(measures)
            MEASURES(ww,cc) = measures{ww}(TEST);
        end
     

    
    end
end
    
    
    
end
