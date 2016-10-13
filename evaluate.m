function summary_selection=evaluate(list,frameScore,superFrames)

summary_selection=frameScore;
quit=1;
for i=1:length(list)
    start=superFrames(list(i),1);
    if start==1
        quit=superFrames(list(i),2);
    else
        if start>quit+1 
            if quit==1 
                for j=quit:start-1
                    summary_selection(j)=0;
                end
            else
                for j=quit+1:start-1
                    summary_selection(j)=0;
                end
            end
        end
        quit=superFrames(list(i),2);
    end
end
for i=quit+1:length(frameScore)
    summary_selection(i)=0;
end
    


