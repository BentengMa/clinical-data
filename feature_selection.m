%%
load A
real_data=A;
train_data=real_data(:,1:87);           % the clinical data
labels=real_data(:,88);                 % the label of the clinical data
evalFN  =   'eval_libsvm';
selectFN    = 'normGeomSelect';         % the selection function
selectOps   = 0.08;                     % the parameter of the selection function
epsilon     = 5;                        % Threshold for two fittness to differ
gen         = 1; 			            % Current Generation Number
maxGen=100;                             % the max generation
dimen=87;      
xZomeLength=dimen+1;                    % the dimensionality of the raw clinical data
mu=3;                                   % the number of selected features
num_pop=1;                              % number of population
popSize=1000;                           % the size of population
x=1:dimen;
numVars=dimen;
best=zeros(maxGen-1,2+dimen);           % the best individual in each generation
gen_sum=1;                              % number of generations
count=1;                           
%%  %Initialization
 startPop=zeros(popSize,xZomeLength+1);
 tempPop =zeros(popSize,xZomeLength+1); 
 
    for i=1:popSize
            dimen_rand=randperm(dimen);
            dimen_choose=dimen_rand(1:mu);
            startPop(i,dimen_choose)=1;    
            dimen_rand2=randperm(dimen); 
            dimen_choose2=dimen_rand2(1:mu);
            tempPop(i,dimen_choose)=1;           
    end
%% Evaluate the fitness

for i=1:popSize
     [startPop(i,xZomeLength),startPop(i,xZomeLength+1)]=feval(evalFN ,train_data,labels,startPop(i,:));
end
for i=1:popSize
     [tempPop(i,xZomeLength),tempPop(i,xZomeLength+1)]=feval(evalFN ,train_data,labels,tempPop(i,:));
end

while (gen_sum<maxGen)
n_choose_temp=zeros(1,popSize);
endPop=startPop;
pastPop=endPop;
select_best=endPop;
endtempPop= feval(selectFN,startPop,[gen_sum selectOps]);   
[selectbest_value ,selectbest_inx]=max(endtempPop(:,end));
select_best(gen_sum,:)=endtempPop(selectbest_inx,:);
new_startPop=zeros(popSize,dimen+2); 
new_endtempPop=zeros(popSize,dimen+2);

   for i =1:popSize
       idx1=find(startPop(i,1:dimen)==1);
       idx2=find(endtempPop(i,1:dimen)==1);
       n1=length(idx1);
       n2=length(idx2);
       n3=min([n1 n2]);
       mid=round(0.5*n3);
       new_idx1=[idx2(1:mid) idx1(mid+1:n1)];
       new_idx2=[idx1(1:mid) idx2(mid+1:n2)];
       unique_1=unique(new_idx1);
       unique_2=unique(new_idx2); 
       if length(unique_1)< n1
           SN=setdiff([1:dimen],unique_1); %SN存放0的位置
           SN_length=length(SN);
           one_rand=randperm(SN_length);
           one_change=one_rand(1:n1-length(unique_1));
           new_startPop(i,SN(one_change))=1;
       end
       if length(unique_2)< n2
           SN_2=setdiff([1:dimen],unique_2);
           SN_length_2=length(SN_2);
           one_rand_2=randperm(SN_length_2);
           one_change_2=one_rand_2(1:n2-length(unique_2));
           new_endtempPop(i,SN_2(one_change_2))=1;
       end
       new_startPop(i,new_idx1)=1;
       new_endtempPop(i,new_idx2)=1;
       endPop(i,1:dimen)=new_startPop(i,1:dimen);
        if sum(endPop(i,1:dimen))==0
            pause()
        end
   end
 %%  mutation   
   for i=1:mutOps(1)
       
       if  rand<mutOps(2)
           
           a=round(rand*(popSize-1)+1);  
           a_size=length(find(endPop(a,1:dimen)==1)); 
           b_size=a_size+1;                    
           zeros_a=find(endPop(a,1:numVars)==0);
           zeros_a_length=length(zeros_a);
           if zeros_a_length>0
           ones_a=find(endPop(a,1:numVars)==1);
           ones_a_length=length(ones_a);
           a_m=randi([1 zeros_a_length],1,1);
           a1=zeros_a(a_m);
           endPop(a,a1)=1; 
           b_pos=find(sum(endPop(:,1:dimen),2)==b_size);
           b=b_pos(1);
           zeros_b=find(endPop(b,1:numVars)==0);%存放的是位置
           zeros_b_length=length(zeros_b);
           ones_b=find(endPop(b,1:numVars)==1);
           ones_b_length=length(ones_b);
           b_m=randi([1 ones_b_length],1,1);
           b1=ones_b(b_m);
           endPop(b,b1)=0;
           end
       end
   end   
  %%  
for i=1:popSize
      [endPop(i,xZomeLength),endPop(i,xZomeLength+1)]=feval(evalFN ,train_data,labels,endPop(i,:));
end

    [bestvalue, bestinx] = max(endPop(:, xZomeLength+1));      % the best individual in the current generation 
    best(gen_sum,:)=endPop(bestinx,:);
    gen_sum=gen_sum+1;
    pastPop=endPop;
    startPop=endPop; 		%Swap the populations 
    evolution_ana{gen_sum}=endPop;
%     Keep the best solution
end       





