function visualSeq(frames)
jconn=[20     1     2     1     8    10     2     9    11     3     4     7     7     5     6    14    15    16    17;
    3     3     3     8    10    12     9    11    13     4     7     5     6    14    15    16    17    18    19];
jconn=jconn';
    for j = 1:size(frames,2)
        frame = frames(:,j,:);
        figure(1);clf;axis equal;
        xlim = [-800 800];
        ylim = [-800 800];
        zlim = [-800 800];
        set(gca, 'xlim', xlim,'ylim', ylim,'zlim', zlim);
        hold on;
        plot3(frame(:,1),frame(:,2),frame(:,3),'ro');
        for k=1:size(jconn,1)
            plot3(frame(jconn(k,:),1),frame(jconn(k,:),2),frame(jconn(k,:),3),'marker','o','MarkerSize',5);
%             text(frame(jconn(k,1),1),frame(jconn(k,1),2),frame(jconn(k,1),3),sprintf('%f %f %f',frame(13,:)));
        end
        
    end
end