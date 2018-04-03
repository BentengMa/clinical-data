 function [acc]=eval_libsvm(train_data,labels,p1,ii)
 v=30;
 kkk=ii;
 right=0;
 predict_labels =[];
[num,dim] = size(train_data);
choose= find(p1(1:dim)==1); 
train_small=train_data(:,choose); 
[m,n]=size(train_small);
kk=0;
idx=[];
for i=1:m
    if numel(find(isnan(train_small(i,:))))==0
        kk=kk+1;
        idx=[idx;i];
    end
end
if sum(sum(p1(1:dim)))==0
    fitness=0;
end
labels_small=labels(idx);
data2=train_small(idx,:);
data=data2;
features=data;
classes=labels_small;
[mm,nn]=size(data);
feature_all=[data labels_small];
num0 = find(feature_all(:,end)==0);
num1 = find(feature_all(:,end)==1);
num_0=length(num0);
num_1=length(num1);
num_all=num_0+num_1;
idx=randperm(num_all);
feature_all=feature_all(idx,:);
    cmd=['-t 0 -b 1 '];
    Test_labels = [];
    dec_values = [];
    predict_labels =[];
    result = zeros(1,v);
    
    num0 = find(feature_all(:,end)==0);
    num1 = find(feature_all(:,end)==1);
    step0 = floor(size(feature_all(num0,:),1)/v);
    step1 = floor(size(feature_all(num1,:),1)/v);
    feature_all0 = feature_all(num0,:);
    feature_all1 = feature_all(num1,:);
    for j = 1:v
        if j~= v
            startpoint0=(j-1)*step0+1;
            endpoint0=(j)*step0;
        else
            startpoint0=(j-1)*step0+1;
            endpoint0=size(feature_all0,1);
        end
        if j~= v
            startpoint1=(j-1)*step1+1;
            endpoint1=(j)*step1;
        else
            startpoint1=(j-1)*step1+1;
            endpoint1=size(feature_all1,1);
        end
        %%%% test set position
        cv_p0=startpoint0:endpoint0;
        cv_p1=startpoint1:endpoint1;
        %%%%%%%%%%%%%% test set
        Test_data0=feature_all0(cv_p0,1:end-1);
        Test_lab0=feature_all0(cv_p0,end);  %%%%label
        Test_data1=feature_all1(cv_p1,1:end-1);
        Test_lab1=feature_all1(cv_p1,end);  %%%%label
        Test_data = [Test_data0;Test_data1];
        Test_lab = [Test_lab0;Test_lab1];  %%%%label
        %%%%%%%%%%%%%% training data
        Train_data0 = feature_all0(:,1:end-1);
        Train_lab0 = feature_all0(:,end);
        Train_data0(cv_p0,:) = '';
        Train_lab0(cv_p0,:) = '';
        Train_data1 = feature_all1(:,1:end-1);
        Train_lab1 = feature_all1(:,end);
        Train_data1(cv_p1,:) = '';
        Train_lab1(cv_p1,:) = '';
        Train_data = [Train_data0;Train_data1];
        Train_lab = [Train_lab0;Train_lab1];  %%%%label
        
        [train_data, settings] = mapminmax(Train_data');
        test_data = mapminmax('apply',Test_data', settings);
  
  
        model = svmtrain(Train_lab,train_data',cmd);
        [predict_label, acc, dec_value] = svmpredict(Test_lab,test_data',model);
         Test_labels = [Test_labels;Test_lab];
         predict_labels = [predict_labels;predict_label];  
    end

for i=1:length(predict_labels)
    if predict_labels(i)==Test_labels(i)
        right=right+1;
    end
end
    acc=right/length(predict_labels);
 end


 