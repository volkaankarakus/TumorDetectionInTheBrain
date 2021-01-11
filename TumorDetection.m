folder='tumor';
fullMatFileName1=fullfile(folder,'image95.mat');
s1=load(fullMatFileName1);
fullMatFileName11=fullfile(folder,'tumor95.mat');
s11=load(fullMatFileName11);
a=imfilter(s1.im,s11.tumormask,'corr');
b=normxcorr2(a,s1.im);
while 1
    option=input('Enter the desired method : \n1)K-Means\n2)Fuzzy C-Means\n3)Otsu Method :');
    switch option
        case (~(option==1 || option==2 || option==3))
            disp(['The number ' int2str(option) ' does not comply with the given conditions.\nPlease enter a suitable number :']);
            continue
        case 1
            K=input('Enter the K value :');
            ab=im2double(b);
            nrows = size(ab,1);
            ncols = size(ab,2);
            ab = reshape(ab,nrows*ncols,1);
            % repeat the clustering 3 times to avoid local minima
            [cluster_idx, cluster_center] = kmeans(ab,K,'distance','sqEuclidean', 'Replicates', 3);
            pixel_labels = reshape(cluster_idx,nrows,ncols);
            figure()
            subplot(221);imshow(s1.im);title('image95');
            subplot(222);imshow(s11.tumormask);title('tumor95');
            subplot(223);imshow(b);title('template95');
            subplot(224);imshow(pixel_labels,[]);title('K-Means'); 
            
        case 2
            fim=mat2gray(b);
            level=graythresh(fim);
            bwfim=im2bw(fim,level);
            data=reshape(fim,[],1);
            [center,member]=fcm(data,3);
            [center,cidx]=sort(center);
            member=member';
            member=member(:,cidx);
            [maxmember,label]=max(member,[],2);
            level=(max(data(label==2))+min(data(label==3)))/2;
            bw=im2bw(fim,level);
            figure()
            subplot(221);imshow(s1.im);title('image95');
            subplot(222);imshow(s11.tumormask);title('tumor95');
            subplot(223);imshow(b);title('template95');
            subplot(224);imshow(bw);title('Fuzzy C-Means');
            
        case 3
            [counts,x]=imhist(b,255);
            [T,EM]=otsuthresh(counts); %Histogram counts, specified as a vector of nonnegative numbers.
            BW=imbinarize(b,T);
            figure()
            subplot(221);imshow(s1.im);title('image95');
            subplot(222);imshow(s11.tumormask);title('tumor95');
            subplot(223);imshow(b);title('template95');
            subplot(224);imshow(BW);title('Otsu Threshold ');
    end
end
