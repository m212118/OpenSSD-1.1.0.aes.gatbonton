classes2=labels{1}; % strip off the class name from labels array
p=size(classes2);
rows=p(1);
classnums=zeros(rows,1); % assign numbers to each of the classes
classnames=classes; % these are the actual class names

for k=1:rows
    for s=1:length(classnames)
        if strcmp(char(classes2(k)),classnames(s))
            classnums(k)=s;
            break;
        end
    end
end
    

% now convert classes and labels into 1 matrix for use with the
% Classification Learner App...

v=[classnums feat_matrix];


% input v into classification learner, set up PCA in the App

c1c2=[v(find(v(:,1)==1),:); v(find(v(:,1)==2),:)];

c1c3=[v(find(v(:,1)==1),:); v(find(v(:,1)==3),:)];

c1c4=[v(find(v(:,1)==1),:); v(find(v(:,1)==4),:)];

c1c5=[v(find(v(:,1)==1),:); v(find(v(:,1)==5),:)];

c1c6=[v(find(v(:,1)==1),:); v(find(v(:,1)==6),:)];

c1c7=[v(find(v(:,1)==1),:); v(find(v(:,1)==7),:)];

c1c8=[v(find(v(:,1)==1),:); v(find(v(:,1)==8),:)];

c2c3=[v(find(v(:,1)==2),:); v(find(v(:,1)==3),:)];

c2c4=[v(find(v(:,1)==2),:); v(find(v(:,1)==4),:)];

c2c5=[v(find(v(:,1)==2),:); v(find(v(:,1)==5),:)];

c2c6=[v(find(v(:,1)==2),:); v(find(v(:,1)==6),:)];

c2c7=[v(find(v(:,1)==2),:); v(find(v(:,1)==7),:)];

c2c8=[v(find(v(:,1)==2),:); v(find(v(:,1)==8),:)];




