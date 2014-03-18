function [frames,decimated] = extractKeyFrameSI(frames,thresh)
    curerr = 0; %% current error
%     for i =1:size(frames,2)
%         for j = 1:size(frames,1)
%             if frames(j,i,2)<-10000
%                 frames(j,i,2)=400;
%             end
%         end
%     end
    oriframes = frames;
    decimated = [];
    extractionPool=[2:size(frames,2)-1];
    while (size(frames,2)-numel(decimated))>thresh
        % iterate each frame
        errs = [];
        remaining = setdiff(extractionPool,decimated);
        for i = remaining
            % how much error occur if decimate this frame
            err = computeerr(oriframes,frames,i,decimated);
            errs = [errs,abs(err)];
        end
        [mindiff,mini] =min(errs);% select the minimum error frame
        deci=remaining(mini);
        decimated = insertorder(deci,decimated);
        [s,e]=findintv(decimated,deci);
        frames = interpolate(frames,decimated(s),decimated(e));
%         (size(frames,2)-numel(decimated))
    end
end

function frames = interpolate(frames,s,e)
    % bi-linear interpolation
    for i = s:e
        ori = frames(:,i,:);
        frames(:,i)=(i-s+1)/(e-s+2)*frames(:,e+1)+(e-i+1)/(e-s+2)*frames(:,s-1);
    end
end

function err = computeerr(oriframes,frames,deci,decimated)
    %% compare current sequence with the original sequence
%     newframe = interpolate(frames,deci);
    [decimated,posi] = insertorder(deci,decimated);
    %% find consecutive numbers 
    [s,e]=findintv(decimated,deci,posi);
    frames = interpolate(frames,decimated(s),decimated(e));
    % compute errors
    framediff = oriframes(:,:)-frames(:,:);
    err = 0;
    for i = 1:size(framediff,2)% each frame
        err = err + norm(framediff(:,i));
    end
end

function c = mergesorted(a,b)
    ai = 1;
    bj = 1;
    c=[];
    while ai<=numel(a) || bj<=numel(b)
        if ai>numel(a)
            c=[c,b(bj:end)];
            return;
        end
        if bj>numel(b)
            c=[c,a(ai:end)];
            return;
        end
        if a(ai)<b(bj)
            c = [c,a(ai)];
            ai = ai +1;
        elseif a(ai)>=b(bj)
            c = [c,b(bj)];
            bj = bj +1;
        end
    end
end

function [newarray,posi] = insertorder(newi,intarray)
    % insert intarray with order
    posi=1;
    if numel(intarray)==0
        newarray = [newi];
        return
    end
    
    for i = 1:(numel(intarray)+1)
        if i>numel(intarray)
            newarray = [intarray,newi];
            return
        end
        if newi < intarray(i)
            break;
        end
    end
    newarray = [intarray(1:i-1),newi,intarray(i:end)];
    posi=i;
end

function [s,e]=findintv(intarr,targetv,posi)
   % find a consecutive int sequence that contain targetv
    position = find(intarr==targetv);
    s = position;
    e = position;
    for i = position:-1:1
        if intarr(s)-intarr(i)<=1
            s=i;
        else
            break;
        end
    end
    for i = position:numel(intarr)
        if intarr(i)-intarr(e)<=1
            e=i;
        else
            break;
        end
    end
        
%     s = 1;
%     e = 1;
%     for i=1:numel(intarr)
%         if (intarr(i)-intarr(e))<=1
%             e=i;
%         else
%             if intarr(s)<=targetv && intarr(e)>=targetv
%                 return
%             end
%             s=i;
%             e=i;
%         end
%     end
end