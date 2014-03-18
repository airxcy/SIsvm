function [M,precision] = confMatrix(testset,trainstats) 
    M = zeros(trainstats.CN,trainstats.CN);
    for j=1:numel(testset)
        if(testset(j).inference>0)
            M(testset(j).class,testset(j).inference)=M(testset(j).class,testset(j).inference)+1;
        end
    end
    %%precision
    precision = zeros(size(M,1),1);
    for i = 1:size(M,1)
        precision(i)= M(i,i)/sum(M(i,:));
    end
end