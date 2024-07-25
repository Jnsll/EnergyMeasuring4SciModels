rng("default")

load data input output

%�ڵ����
inputnum = 2;
hiddennum = 5;
outputnum = 1;

%ѵ�����ݺ�Ԥ������
input_train = input(1:1900,:)';
input_test = input(1901:2000,:)';
output_train = output(1:1900)';
output_test = output(1901:2000)';

%ѡ����������������ݹ�һ��
[inputn,inputps] = mapminmax(input_train);
[outputn,outputps] = mapminmax(output_train);

%��������
net = newff(inputn,outputn,hiddennum);

%% �Ŵ��㷨������ʼ��
maxgen = 10;                         %��������������������
sizepop = 10;                        %��Ⱥ��ģ
pcross = 0.3;                       %�������ѡ��0��1֮��
pmutation = 0.1;                    %�������ѡ��0��1֮��

%�ڵ�����
numsum = hiddennum * (inputnum + outputnum + 1) + outputnum;

lenchrom = ones(1,numsum);
bound = [-3 * ones(numsum,1),3 * ones(numsum,1)];    %���ݷ�Χ

individuals = struct('fitness',zeros(1,sizepop), 'chrom',[]);  %����Ⱥ��Ϣ����Ϊһ���ṹ��

%��ʼ����Ⱥ
for i = 1:sizepop
    %�������һ����Ⱥ
    individuals.chrom(i,:) = Code(lenchrom,bound);    %���루binary��grey�ı�����Ϊһ��ʵ����float�ı�����Ϊһ��ʵ��������
    x = individuals.chrom(i,:);

    %������Ӧ��
    individuals.fitness(i) = fun(x,inputnum,hiddennum,outputnum,net,inputn,outputn);   %Ⱦɫ�����Ӧ��
end

%����õ�Ⱦɫ��
[bestfitness,bestindex] = min(individuals.fitness);
bestchrom = individuals.chrom(bestindex,:);  %��õ�Ⱦɫ��
avgfitness = sum(individuals.fitness) / sizepop; %Ⱦɫ���ƽ����Ӧ��

% ��¼ÿһ����������õ���Ӧ�Ⱥ�ƽ����Ӧ��
trace = zeros(maxgen + 1,2);
trace(1,:) = [avgfitness,bestfitness];

%% ���������ѳ�ʼ��ֵ��Ȩֵ
for i = 1:maxgen
    % ѡ��
    individuals = Select(individuals,sizepop);
    %����
    individuals.chrom = Cross(pcross,lenchrom,individuals.chrom,sizepop,bound);
    % ����
    individuals.chrom = Mutation(pmutation,lenchrom,individuals.chrom,sizepop,i,maxgen,bound);

    % ������Ӧ��
    for j = 1:sizepop
        x = individuals.chrom(j,:); %����
        individuals.fitness(j) = fun(x,inputnum,hiddennum,outputnum,net,inputn,outputn);
    end

    %�ҵ���С�������Ӧ�ȵ�Ⱦɫ�弰��������Ⱥ�е�λ��
    [newbestfitness,newbestindex] = min(individuals.fitness);
    [worestfitness,worestindex] = max(individuals.fitness);

    % ������һ�ν�������õ�Ⱦɫ��
    if bestfitness > newbestfitness
        bestfitness = newbestfitness;
        bestchrom = individuals.chrom(newbestindex,:);
    end
    individuals.chrom(worestindex,:) = bestchrom;
    individuals.fitness(worestindex) = bestfitness;

    avgfitness = sum(individuals.fitness) / sizepop;

    trace(i + 1,:) = [avgfitness,bestfitness]; %��¼ÿһ����������õ���Ӧ�Ⱥ�ƽ����Ӧ��

end

%% �Ŵ��㷨�������
figure(1)
r = maxgen + 1;
plot((1:r)',trace(:,2),'b--');
title(['��Ӧ������  ' '��ֹ������',num2str(maxgen)]);
xlabel('��������');
ylabel('��Ӧ��');
legend('ƽ����Ӧ��','�����Ӧ��');
disp('��Ӧ��                   ����');
x = bestchrom;

%% �����ų�ʼ��ֵȨֵ��������Ԥ��
fact1 = inputnum * hiddennum;
fact2 = hiddennum * outputnum;
sum1 = fact1 + hiddennum;
sum2 = sum1 + fact2;

w1 = x(1        :fact1);
B1 = x(fact1 + 1:sum1);
w2 = x(sum1  + 1:sum2);
B2 = x(sum2  + 1:sum2 + outputnum);

net.iw{1,1} = reshape(w1,hiddennum,inputnum);
net.lw{2,1} = reshape(w2,outputnum,hiddennum);
net.b{1} = reshape(B1,hiddennum,1);
net.b{2} = B2;

%% BP����ѵ��
net.trainParam.epochs = 100;
net.trainParam.lr = 0.1;

%����ѵ��
net = train(net,inputn,outputn);

%% BP����Ԥ��
inputn_test = mapminmax('apply',input_test,inputps);
an = sim(net,inputn_test);
test_simu = mapminmax('reverse',an,outputps);
error = test_simu - output_test;
