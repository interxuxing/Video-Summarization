
function [score]=superScore(superFrames,frameScore)
%superFrames存储的是分割点，而framesScore存储的是每一帧的得分 
n=size(superFrames,1);
I=zeros(n,1);
for i=1:n
    change=superFrames(i,:);
    for j=change(1):change(2)
        I(i)=I(i)+frameScore(j);
    end
end
score=I;
end



        
        
        
        