dataDir = 'keyframes/';
jconn=[20     1     2     1     8    10     2     9    11     3     4     7     7     5     6    14    15    16    17;
    3     3     3     8    10    12     9    11    13     4     7     5     6    14    15    16    17    18    19];
jconn=jconn';
load('skel.mat');
actions = [];
rowNumb = 100;
for a=1:20
    actionset=[];
    for s=1:10
        for e=1:3
            fstem=sprintf('a%02i_s%02i_e%02i',a,s,e);
            [frames,SI,existfile]=loadSIandJoint(fstem,skel);
            if numel(frames)>0 && numel(SI)>0
                actionobj.frames = frames;
                actionobj.len = size(frames,2);
                actionset=[actionset,actionobj];
            end
        end
    end
    rowNumb = max([actionset.len]);
    hdl1 = figure('Visible','off');clf;axis equal;
    xlim = [0 rowNumb*100+400];
    ylim = [-numel(actionset)*200+100 400];
    zlim = [0 800];
    set(gca, 'xlim', xlim,'ylim', ylim,'zlim', zlim);
    hold on;
    for rowcount = 1:numel(actionset)
        frames = actionset(rowcount).frames;
        for i=1:size(frames,2)
             frame = [frames(:,i,1), frames(:,i,2), frames(:,i,3)];
             offset = repmat([(i-1)*100,-rowcount*200, 0],[size(frame,1) 1]);
             frame = frame+offset;
             for j=1:size(jconn,1)
                plot3(frame(jconn(j,:),1),frame(jconn(j,:),2),frame(jconn(j,:),3));
             end
        end
    end
%     drawnow;
    print(hdl1,'-dpng','-r300',sprintf('action_%d.png',a))
%     saveas(hdl1,sprintf('action_%d.fig',a),'fig');
%     pause;
end
