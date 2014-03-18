addpath(genpath('libsvm-3.17/'));
addpath('utils/');
load('trainstats.mat')
load('skel.mat');
%% build trainset
actionset = [];
g=1:20;
for a=g
    for s = 1:10
        for e=1:3
            % exclude 10 as seggested MSR action3d data set
            foundit = false;
            for j = 1:size(trainstats.MSRexclude,1)
                if strcmp(sprintf('a%02i_s%02i_e%02i',a,s,e),trainstats.MSRexclude(j,:))
                    foundit = true;
                end
            end
            if foundit
                continue;
            end
            fstem=sprintf('a%02i_s%02i_e%02i',a,s,e);
            [frames,SI,bonelen,existfile]=loadSIandJoint(fstem,skel);
            if numel(frames)>0 && numel(SI)>0
                actionobj.frames=frames;
                actionobj.SI = SI;
                actionobj.len = size(SI,2);
                actionobj.class = a;
                actionobj.subject = s;
                actionobj.e = e;
                actionobj.fstem = fstem;
                actionobj.counter = 0;
                actionobj.inference = 0;
                actionset = [actionset,actionobj];
            end
        end
    end
end
%% cross subjects 5 subjects for train, 5 subjects for test
preM=[];
trainsub = [1 3 5 7 9];
trainidx = [];
for i = trainsub
    subi = find([actionset.subject]==i);
    trainidx = [trainidx,subi];
end
trainidx = sort(trainidx);
testidx = setdiff(1:size(actionset,2),trainidx);
numofdim = 20;
testset= actionset(testidx);
trainset=actionset(trainidx);
%% PCA
pcaCoef=[];
vcarray=[];
for i = g
    allSI = cat(2,trainset(find([trainset.class]==i)).SI)';
    [eigvector, eigvalue,latent,tsquare] = princomp(allSI);
    pcaCoef(i).eigvector = eigvector(:,1:numofdim);
    pcaCoef(i).eigvalue = eigvalue;
    varcaped = cumsum(latent)./sum(latent);
    varcaped = varcaped(numofdim);
    vcarray(i)=varcaped;
    actionidx = find([trainset.class]==i);
    for j = actionidx
        pcavec = trainset(j).SI'*eigvector(:,1:numofdim);
        trainset(j).SI = pcavec';
    end
end
%% finding templates of each action from trainset
[trainset,outlier,centroids]=alignframes(trainset,g);

%% svm and template alignment
trainclass = [trainset.class]';
subidx = [trainset.subject]';
actionclass = [actionset.class]';
testclass = [testset.class]';
svmpreds=[];
svmdecs=[];
args = ' -q';
accs=[];
distmat =[];
for centroidsi = g
    trainclass = [trainset.class]';
    t = centroids(find(g==centroidsi));
    distlist = [];
    % apply pca projection
    pcaactionset=[];
	eigvector = pcaCoef(centroidsi).eigvector;
    for i = 1:numel(actionset)
        pcavec = actionset(i).SI'*eigvector;
        pcaactionset(i).SI = pcavec';
        pcaactionset(i).frames = actionset(i).frames;
        pcaactionset(i).class = actionset(i).class;
    end
    % align the training and testing frames to current template
    newactionset=[];
    for i = 1:numel(pcaactionset)
        [Dist,w]=dtwSI(t,pcaactionset(i));
        distlist = [distlist;Dist];
        newFrame = zeros(size(t.frames));
        newSI = zeros(size(t.SI));
        for j = 1:size(t.frames,2)
            matchingidx = find(w(:,1)==j);
            for k = matchingidx'
                newFrame(:,j,:)=newFrame(:,j,:)+pcaactionset(i).frames(:,w(k,2),:);
                newSI(:,j)=newSI(:,j)+pcaactionset(i).SI(:,w(k,2));
            end
            newFrame(:,j,:)=newFrame(:,j,:)/numel(matchingidx);
            newSI(:,j)=newSI(:,j)/numel(matchingidx);
        end
        newactionset(i).frames = newFrame;
        newactionset(i).SI = newSI;
        newactionset(i).class = pcaactionset(i).class;
    end
    % reshape to 1-D vectors nXd
    actiondata = [];
    for i =1:numel(newactionset)
        actiondata = [actiondata;[reshape(newactionset(i).SI,numel(newactionset(i).SI),1)']];
    end
    traindata = actiondata(trainidx,:);
    
    % compute the euclidean distance
    tempvec = repmat(reshape(t.SI,numel(t.SI),1)',numel(actionset),1);
    diffmat=actiondata-tempvec;
    distarray = sum(diffmat.^2,2);
    distmat=[distmat,distarray];
    
    % svm
    trainlabel=[trainclass==centroidsi]*2-1;
    model = svmtrain(trainlabel, traindata, ['-t 0',args]);
    actionlabel=[actionclass==centroidsi]*2-1;
    [predict_label_P, accuracy_P, dec_values_P] = svmpredict(actionlabel, actiondata, model);
    accs=[accs,accuracy_P];
    svmpreds = [svmpreds,predict_label_P];
    svmdecs = [svmdecs,dec_values_P];
end

%% classification
traindecmatrix=svmdecs(trainidx,:);
testdecmatrix=svmdecs(testidx,:);
classset = g;
resultlabel = zeros(size(testclass));
distmat=distmat(testidx,:);
predmat=testdecmatrix;
% make sure the testset stays unknown
testset=actionset(testidx);
predmatrix=[];
for i = 1:numel(testclass)
    testset(i).class = testclass(i);
    testset(i).inference =0;
    predarray = predmat(i,:);
    predarray = ((predarray>0).*predarray)./(distmat(i,:).^0.5)+((predarray<0).*predarray).*(distmat(i,:).^1.5);
    predmatrix=[predmatrix;predarray];
    [maxvalue,maxclass]=max(predarray);
    testset(i).inference = classset(maxclass);
    resultlabel(i)=classset(maxclass);
end

%% displaying result
[M,precision] = confMatrix(testset,trainstats);
M = M(g,:);
M = M(:,g);
totalpre=sum(diag(M))/sum(sum(M));
disp(sprintf('%d mean precision: %f',numofdim,totalpre))
M=M./repmat(sum(M,2),1,20);
precision = precision(g);
mean(precision);
hdl=figure(1);
imagesc(M);figure(gcf);
set(gca,'XTick',1:20)
set(gca,'YTick',1:20)
set(gca,'YTickLabel',trainstats.class)
set(gca,'XTickLabel',trainstats.class)
xticklabel_rotate;
strnum = [];
[x,y]=find(M>0);
for i = 1:numel(y)
strnum=[strnum,{sprintf('%.2f',M(x(i),y(i))*100)}];
end
text(y,x,strnum,'Color',[0 0 0],'HorizontalAlignment','center','FontWeight','bold','FontSize',7);
drawnow;
print(hdl,'-dpng','-r150','confM.png');
genHtml( 'classificationDetail.html',M,trainset,testset,trainstats);

