function [frames] = refineframes(frames,skel)
jconn=[20     1     2     1     8    10     2     9    11     3     4     7     7     5     6    14    15    16    17;
    3     3     3     8    10    12     9    11    13     4     7     5     6    14    15    16    17    18    19];
jconn=jconn';
        % to solve cross leg problem
    for i = 1:size(frames,2)
        frame = [frames(:,i,1),frames(:,i,2),frames(:,i,3)];
        
        if norm(frame(6,:)-frame(15,:)) > norm(frame(6,:)-frame(14,:))
            tempPos = frame(14,:);
            frame(14,:) = frame(15,:);
            frame(15,:) = tempPos;

            % update correspondance
            tempPos = frame(16,:);
            frame(16,:) = frame(17,:);
            frame(17,:) = tempPos;

            tempPos = frame(18,:);
            frame(18,:) = frame(19,:);
            frame(19,:) = tempPos;
        end
        
        frame = getrelative(frame,skel.tree,skel.root,skel.root);
        for j =[1:skel.root-1,skel.root+1:size(frame,1)]
            frame(j,:)=frame(j,:)/norm(frame(j,:));
        end        
        frames(:,i,1)=frame(:,1);
        frames(:,i,2)=frame(:,2);
        frames(:,i,3)=frame(:,3);

%         visRelative(frame,skel.tree,skel.root,[0 0 0]);
%         pause;
    end
end

function frame = getrelative(frame,tree,root,parent)
    for i = tree(root).children
        frame = getrelative(frame,tree,i,root);
    end
    frame(root,:) = (frame(root,:)-frame(parent,:));
end

function frame = getglobal(frame,tree,root,parent,meanbonelen)
    frame(root,:) = (frame(root,:)*meanbonelen(root)+frame(parent,:));
    for i = tree(root).children
        frame = getglobal(frame,tree,i,root,meanbonelen);
    end
end
function visRelative(frame,tree,root,pcoor)
    plot3([pcoor(1),pcoor(1)+frame(root,1)],[pcoor(2),pcoor(2)+frame(root,2)],[pcoor(3),pcoor(3)+frame(root,3)]);
    pcoor = pcoor + frame(root,:);
    text(pcoor(1),pcoor(2),pcoor(3),sprintf('%d',root));
    for i = tree(root).children
        visRelative(frame,tree,i,pcoor);
    end
end