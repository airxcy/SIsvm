function [ output_args ] = genHtml( fname,M,trainset,testset,trainstats)
    %% generate html representation
    fid = fopen(fname,'w');
    htmltxt = [];
    htmltxt = [htmltxt,'<h1>Confusion Matrix</h1>'];
    htmltxt=[htmltxt,'<img src="confM.png"/><br>'];
    
    htmltxt = [htmltxt,'\n<h1>Training Set</h1>\n'];
    for j=1:trainstats.CN
        htmltxt=[htmltxt,trainstats.class{j},':'];
        for k=find([trainset.class]==j)
            htmltxt=[htmltxt,'<a href="','imgs/',trainset(k).fstem,'.png"><img src="','imgs/',trainset(k).fstem,'.png" width="500"/></a>',num2str(trainset(k).counter)];
        end
        htmltxt=[htmltxt,'<br>\n'];
    end
    
    htmltxt = [htmltxt,'\n<h1>Matching Table</h1>\n'];
    htmltxt=[htmltxt,'<table border="1">\n<tr>\n'];
    for j=1:trainstats.CN
        htmltxt=[htmltxt,'<th>',trainstats.class{j},'</th>'];
    end
    htmltxt=[htmltxt,'\n</tr>\n'];
    for j=1:trainstats.CN
        htmltxt=[htmltxt,'<tr>\n'];
        for k = 1:trainstats.CN
            htmltxt=[htmltxt,'<td>\n'];
            linecount = 0;
            for l=intersect(find([testset.class]==j),find([testset.inference]==k))
                htmltxt=[htmltxt,'<a href="','imgs/',testset(l).fstem,'.png"><img src="','imgs/',testset(l).fstem,'.png" width="500"/></a>'];
                linecount=linecount+1;
%                 if mod(linecount,7)==0
                    htmltxt=[htmltxt,'<br>\n'];
%                 end
            end
            htmltxt=[htmltxt,'</td>\n'];
        end
        htmltxt=[htmltxt,'</tr>\n'];
    end
    htmltxt=[htmltxt,'</tr></table>\n'];
    fprintf(fid,htmltxt);
    fclose(fid);
end

