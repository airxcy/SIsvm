function [actionset,outlier,centroids]=alignframes(actionset,group)
    outlier=[];
    centroids =[];
    for a = group
        actionidx=find([actionset.class]==a);
        distarray=[];
        idxarray=[];
        for i = actionidx
            dist=0;
            for j=actionidx
                [d,wd]= dtwSI(actionset(i),actionset(j));
                euDist = 0;
                for k = 1:size(actionset(i).SI,2)
                    matchingidx = find(wd(:,1)==k);
                    diffSI = actionset(i).SI(:,k)-mean(actionset(j).SI(:,wd(matchingidx,2)),2);
                    euDist = euDist + sum(diffSI.^2);
                end
                dist = dist + sqrt(euDist)/size(actionset(i).SI,2);
            end
%             [dist,w] = dtwSI(subjectSet(i),t);
            [distarray,idxarray,posi] = insertorder(dist,distarray,i,idxarray);
        end
        numberOftemplate=7;%numel(actionidx);
%         numberOftemplate=min(7,numel(actionidx));
        lenarry=[actionset(actionidx).len];
        
        meanactionlen = mean([lenarry<100].*lenarry);
        templateSet = idxarray(1:numberOftemplate);
        [~,longestone] = min(abs([actionset(templateSet).len]-meanactionlen));
        
        t.frames = actionset(templateSet(longestone)).frames;
        t.SI = actionset(templateSet(longestone)).SI;
        templateFrame=t.frames;
        templateSI = t.SI;
        for i = templateSet([1:longestone-1,longestone+1:numberOftemplate])
            [Dist,w]=dtwSI(t,actionset(i));
            newFrame = zeros(size(t.frames));
            newSI = zeros(size(t.SI));
            for j = 1:size(t.SI,2)
                matchingidx = find(w(:,1)==j);
                for k = matchingidx'
                    newFrame(:,j,:)=newFrame(:,j,:)+actionset(i).frames(:,w(k,2),:);
                    newSI(:,j)=newSI(:,j)+actionset(i).SI(:,w(k,2));
                end
                newFrame(:,j,:)=newFrame(:,j,:)/numel(matchingidx);
                newSI(:,j) = newSI(:,j)/numel(matchingidx);
            end
            templateFrame = templateFrame+newFrame;
            templateSI = templateSI+newSI;
        end
        templateFrame=templateFrame/numel(templateSet);
        templateSI=templateSI/numel(templateSet);
        t.frames = templateFrame;
        t.SI = templateSI;
        t.len = size(templateSI,2);
        centroids=[centroids,t];
    end
end

function [newarray,newidxarray,posi] = insertorder(newv,oldarray,newi,oldidxarray)
    % insert intarray with order
    posi=1;
    newarray = [newv];
    newidxarray=[newi];
    if numel(oldarray)==0
        newarray = [newv];
        newidxarray=[newi];
        return
    end
    
    for i = 1:(numel(oldarray)+1)
        if i>numel(oldarray)
            newarray = [oldarray,newv];
            newidxarray = [oldidxarray,newi];
            return
        end
        if newv < oldarray(i)
            break;
        end
    end
    newarray = [oldarray(1:i-1),newv,oldarray(i:end)];
    newidxarray = [oldidxarray(1:i-1),newi,oldidxarray(i:end)];
    posi=i;
end
