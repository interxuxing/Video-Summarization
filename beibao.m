
function [score,list]=beibao(superFrames,frameScore)
n=size(superFrames,1);%几段帧
W=round(superFrames(end)*0.15);%总长度
flag=zeros(n+1,W+1);
K=zeros(n+1,W+1);
wt=superFrames(:,2)-superFrames(:,1)+1;
list=[];
score=0;
%n=3;
%W=50;
%K=zeros(4,51);
%flag=zeros(4,51);
% w=1;
% wt=superFrames;

for i=1:n+1
    %abc=10;
    for w=1:W+1
        if i==1||w==1
            K(i,w)=0;
        else if wt(i-1)<=w
            K(i,w)=max(frameScore(i-1)+K(i-1,w-wt(i-1)+1),K(i-1,w));
            if K(i,w)==frameScore(i-1)+K(i-1,w-wt(i-1)+1)
                flag(i,w)=1;
            end
        else
            K(i,w)=K(i-1,w);
        end
       
    end
    end

end
w=W+1;
for i=n+1:-1:1
    if flag(i,w)==1
        list=[list,i-1];
        score=score+frameScore(i-1);
        %fprintf('%d ',wt(i-1));
        w=w-wt(i-1);
    end
end
list=sort(list);
end


% for i=n:-1:2
%     if flag(i,W)==1
% end
            
            



