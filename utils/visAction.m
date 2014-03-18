function visAction(fname)
    jconn=[20     1     2     1     8    10     2     9    11     3     4     7     7     5     6    14    15    16    17;
        3     3     3     8    10    12     9    11    13     4     7     5     6    14    15    16    17    18    19];
    jconn=jconn';
    load(fname);
    hdl1 = figure(1);clf;axis equal;
    xlim = [0 6000];
    ylim = [0 800];
    zlim = [0 800];
    set(gca, 'xlim', xlim,'ylim', ylim,'zlim', zlim);
    hold on;
    for i=1:size(frames,2)
        x = frames(:,i,1);
        y = frames(:,i,2);
        z = frames(:,i,3);
        frame = [x, y, z];
        offset = repmat([(i-1)*100,0, 0],[size(frame,1) 1]);
        frame = frame+offset;
        for j=1:size(jconn,1)
            plot3(frame(jconn(j,:),1),frame(jconn(j,:),2),frame(jconn(j,:),3));
        end
    end
end

