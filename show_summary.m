function show_summary(list,imageList,superFrames)
for i=1:length(list)
    for j=superFrames(list(i),1):superFrames(list(i),2)
        imshow(imread(imageList{j}))
        pause(0.02);
    end
    
end
end