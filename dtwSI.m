function [Dist,w] = dtwSI(a,b)
    %Dynamic Time Warping Algorithm
    %Dist is unnormalized distance between t and r
    %D is the accumulated distance matrix
    %k is the normalizing factor
    %w is the optimal path
    %t is the vector you are testing against
    %r is the vector you are testing   
%     adSI = [];
%     bdSI = [];
%     for i = 2:size(a.SI,2)-1
%         Di= ((a.SI(:,i)-a.SI(:,i-1))+(a.SI(:,i+1)-a.SI(:,i-1))/2)/2;
%         adSI = [adSI,Di];
%     end
%     for i = 2:size(b.SI,2)-1
%         Di= ((b.SI(:,i)-b.SI(:,i-1))+(b.SI(:,i+1)-b.SI(:,i-1))/2)/2;
%         bdSI = [bdSI,Di];
%     end
    
    N=size(a.SI,2);
    M=size(b.SI,2);
    for n=1:N
       for m=1:M
%             framea = [a.frames(:,n,1),a.frames(:,n,2),a.frames(:,n,3)];
%             frameb = [b.frames(:,m,1),b.frames(:,m,2),b.frames(:,m,3)];
%             d(n,m) = norm(framea-frameb);
              framea = a.SI(:,n);
              frameb = b.SI(:,m);
              d(n,m) = norm(framea-frameb);
%             d(n,m) = norm(adSI(:,n)-bdSI(:,m))^2;
       end
    end

    D=zeros(size(d));
    D(1,1)=d(1,1);

    for n=2:N
        D(n,1)=d(n,1)+D(n-1,1);
    end
    for m=2:M
        D(1,m)=d(1,m)+D(1,m-1);
    end
    for n=2:N
        for m=2:M
            D(n,m)=d(n,m)+min([D(n-1,m),D(n-1,m-1),D(n,m-1)]);
        end
    end

    Dist=D(N,M);
    n=N;
    m=M;
    k=1;
    w=[];
    w(1,:)=[N,M];
    while ((n+m)~=2)
        if (n-1)==0
            m=m-1;
        elseif (m-1)==0
            n=n-1;
        else 
            [values,number]=min([D(n-1,m),D(n,m-1),D(n-1,m-1)]);
            switch number
                case 1
                n=n-1;
                %         disp('go')
                case 2
                m=m-1;
                %         disp('go')
                case 3
                n=n-1;
                m=m-1;
            end
        end
        k=k+1;
        w=cat(1,w,[n,m]);        
    end
%     w=[[N+2,M+2];w+1;[1,1]];
    Dist = Dist/norm([n,m]);
%     Dist = Dist/size(w,1);
end

