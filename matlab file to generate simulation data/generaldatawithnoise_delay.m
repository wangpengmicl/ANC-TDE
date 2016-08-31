clc
clear all
close all
%% matlab file to generate simulation data
DataLength=10000;       %data length  
D=[3 4];                %time delay between noise
start=21500;            %noise data index
pos=[1 5001];           %noise data start index 
NoiseLen=[1500 1500];   %noise data length
t=1:DataLength;
Noise_Amplitutde=0.1;
Signal_Amplitutde=0.5;
noise_load = load('noisel.mat');
noisel = noise_load.X;

s=Signal_Amplitutde*sin(t*pi/20+0.5);   
s=s';
noise = Noise_Amplitutde*noisel(start+1:start+DataLength);
for i=1:length(D)
    
    d(pos(i):pos(i)+NoiseLen(i)-1,:)=noise(pos(i):pos(i)+NoiseLen(i)-1);
    if(i<length(pos))
        x(pos(i):pos(i+1)-1,:)= Noise_Amplitutde*noisel(start-D(i)+pos(i):start-D(i)+pos(i+1)-1);
        d(pos(i)+NoiseLen(i):pos(i+1)-1,:)=s(pos(i)+NoiseLen(i):pos(i+1)-1)+noise(pos(i)+NoiseLen(i):pos(i+1)-1);
    else
        x(pos(i):DataLength,:)= Noise_Amplitutde*noisel(start-D(i)+pos(i):start-D(i)+DataLength);
         d(pos(i)+NoiseLen(i):DataLength,:)=s(pos(i)+NoiseLen(i):DataLength)+noise(pos(i)+NoiseLen(i):DataLength);
    end
end
    
x(x>10)=10;
x(x<-10)=-10;
d(d>10)=10;
d(d<-10)=-10;

 %% store data in file
 fd=fopen('d_noise.txt','wt');
fx=fopen('x_noise.txt','wt');  
factor=(8192/10);       %转化因子

for i=1:DataLength
        temp=int32(factor*d(i));
        if temp>=8192
        	temp=8191;
        end
         if temp<-8192
            temp=-8192;
         end
        if  temp<0
        	temp=temp+2^14;
       end
        fprintf(fd,'%.4x \n',temp);
        
        temp=int32(factor*x(i));
        if temp>=8192
        	temp=8191;
        end
         if temp<-8192
            temp=-8192;
         end
        if  temp<0
        	temp=temp+2^14;
       end
        fprintf(fx,'%.4x \n',temp);
end
 fclose(fx);
 fclose(fd);
                  