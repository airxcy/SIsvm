function [frames,SI,bonelen,existfile]=loadSIandJoint(fstem,skel)
    frames = [];
    SI = [];
    bonelen=[];
    existfile = [];
    fnameSI=['SI2.5/',fstem,'_SI.mat'];
    fnameJoint=['Joints/',fstem,'_skeleton.mat'];
    existfile=[exist(fnameJoint,'file'),exist(fnameSI,'file')];
    if existfile
        load(fnameSI);
        load(fnameJoint);
        frames = frames(:,:,[1 2 3]);
        [frames] = refineframes(frames,skel);
        myframes = cat(1,frames(:,:,1),frames(:,:,2),frames(:,:,3));
        frames = myframes;
        SI = cat(1,(limbSIn*2-1)*0.6,myframes);
        if any(any(any(isnan(frames))))
            frames=[];
        end
        if any(any(isnan(SI)))
            SI = [];
        end
    end
end