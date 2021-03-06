%% Input Parameters

phenol_cyano_Btime=[30 300 165 165 165 165 210 30];
phenol_cyano_Btemp=[60 60 120 120 120 120 200 200];
furan_epoxy_Btime= [300 300 30 120 120 30];
furan_epoxy_Btemp= [60 200 153 60 200 107];
phenol_epoxy_Btime=[30 30 300 210 300];
phenol_epoxy_Btemp=[60 200 200 60 153];

%% Output Values

phenol_cyano_CS=[23.4 18.65 51.6 55.45 53.25 53.35 5.2 28.75];
phenol_cyano_FS = [13.5 13.4 18.5 16.6 15.1 16.2 2.3 4];
phenol_cyano_cond= [1.692 1.485 1.799 1.547 1.72 1.86] ;
phenol_cyano_speh= [0.954 0.99 0.85 0.838 0.632 0.891];
furan_epoxy_CS= [17 11.6 19.55 12.65 10.95 9.4];
furan_epoxy_FS= [19.1 11.3 25.7 10.4 14.5 6.7];
furan_epoxy_cond= [2.379 0.95 2.568 2.722 2.548];
furan_epoxy_speh= [0.656 0.565 0.847 0.838 0.871];
phenol_epoxy_CS=[16.75 9.9 17.3 11.65 18.2];
phenol_epoxy_FS=[10 15.4 15 19.8 20.6];
phenol_epoxy_cond=[3.472 2.575 2.003 2.351 2.178];
phenol_epoxy_speh= [0.829 0.895 0.882 0.561 0.766];


tiledlayout(4,3)
%% Selection of parameter 
for (run= 1:3)
if run==1
    binder= 1;
elseif run==2
    binder = 2;
    infil = 2;
elseif run==3
    binder = 2;
    infil = 1;
end

PRESS=0;
TSS=0;
TSS1=0;
temp=0;
flag=0;
%binder= input('Enter 1 for Furan and 2 for Phenol: ');
if binder ==2
    %infil= input('Enter 1 for Cyano and 2 for Epoxy: ');
    if infil == 1
        Btime= phenol_cyano_Btime;
        Btemp=phenol_cyano_Btemp;
        CS=phenol_cyano_CS;
        FS=phenol_cyano_FS;
        cond=phenol_cyano_cond;
        speh=phenol_cyano_speh;
        flag=1;
    elseif infil == 2
        Btime=phenol_epoxy_Btime;
        Btemp= phenol_epoxy_Btemp;
        CS= phenol_epoxy_CS;
        FS= phenol_epoxy_FS;
        cond= phenol_epoxy_cond;
        speh= phenol_epoxy_speh;
    end
elseif binder==1
    Btime= furan_epoxy_Btime;
    Btemp=furan_epoxy_Btemp;
    CS=furan_epoxy_CS;
    FS=furan_epoxy_FS;
    cond=furan_epoxy_cond;
    speh=furan_epoxy_speh;
    
end

%test=CS;
%a= input('Enter 1: Compressive Strength, 2: Flexural Strength, 3: Conductivity, 4: Specific Heat');

for (a=1:4)

if a==1
    test=CS;
    exp='Compressive Strength';
    %disp('Compressive Stregth')
elseif a==2
    test=FS;
    exp='Flexural Strength';
    %disp('Flexural Stregth')
elseif a==3
    test=cond;
    exp='Conductivity';
    len=length(test);
    Btime=Btime(1:len);
    Btemp=Btemp(1:len);
    %disp('Conductivity')
elseif a==4
    test=speh;
    exp='Specific Heat';
    len=length(test);
    Btime=Btime(1:len);
    Btemp=Btemp(1:len);
    %disp('Specific Heat')
end

%%
% Fit: 'Dopt'.
[xData, yData, zData] = prepareSurfaceData( Btemp, Btime, test);

%% Setting up equations depending on number of inputs 
% Set up fittype and options.
if length(Btime)==6
ft = fittype( 'a+ b*x+ c*y + d*x*y +  f*x*x', 'independent', {'x', 'y'}, 'dependent', 'z' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.StartPoint = [0.156874251597592 0.999727711922883 0.187255588886038 0.171186687811562 0.0318328463774207];
 
elseif length(Btime)>6
ft = fittype( 'a+ b*x + c*y + d*x*y + e*y*y + f*x*x', 'independent', {'x', 'y'}, 'dependent', 'z' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.StartPoint = [0.156874251597592 0.999727711922883 0.187255588886038 0.171186687811562 0.706046088019609 0.0318328463774207];
%disp('high data') 

elseif length(Btime)==5
ft = fittype( 'a+ b*y + d*x*y +f*x*x', 'independent', {'x', 'y'}, 'dependent', 'z' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.StartPoint = [0.156874251597592 0.999727711922883 0.171186687811562 0.0318328463774207];
 
end

%% R square

% Fit model to data.
[fitresult, gof] = fit( [xData, yData], zData , ft, opts );
TSS=gof.sse/(1-gof.rsquare);
R2=gof.rsquare;
testrep=test(1:4);


% Plot fit with data.

if a==1
    %figure( 'Name', 'Compressive Strength' );
elseif a==2
    %figure( 'Name', 'Flexural Strength' );
elseif a==3
    %figure( 'Name', 'Thermal Conductivity' );
elseif a==4
    %figure( 'Name', 'Specific Heat Capacity' );
end


[x2,y2] = meshgrid(60:200,30:300);
f2 = [fitresult(x2,y2)];
f2(f2 < 0) = 0;
nexttile(3*a + run - 3)
h= contourf( x2,y2, f2);
%colormap (h, default)
hold on
scatter (xData, yData, [],  zData,'filled');
%set(h(2),'MarkerSize',1);
xlabel 'Baking Temperature (^{o}C)'
ylabel 'Baking Time (min)'
if a==1
    if run==1
        title('Furan Epoxy')
    elseif run==2
        title('Phenol Epoxy')
    elseif run==3
        title('Phenol Cyanoacrylate')
    end
end

if run==1
    if a==1
         title({'Compressive', 'Strength'},'position',[25.98848 150.74 5.00011])
    elseif a==2
         title({'Flexural', 'Strength'},'position',[25.98848 150.74 5.00011])
    elseif a==3
         title({'Thermal', 'Conductivity'},'position',[25.98848 150.74 5.00011])
    elseif a==4
         title({'Specific Heat', 'Capacity'},'position',[25.98848 150.74 5.00011])
    end
end

grid on
if run==3    
    h = colorbar;
    if a==1
        title(h, 'MPa')
        caxis([0 50])
    elseif a==2
        title(h, 'MPa')
        caxis([0 25])
    elseif a==3
        title(h, 'W/(m.K)')
        caxis([0.3 3])
    elseif a==4
        title(h, 'J/K')
        caxis([0.5 1.01])
    end
end


    





%% Reproductability

if (flag==1)
for (j=3:6)
    %meant=(test(3)+test(4)+test(5)+test(6))/4
    test(j);
    yfit=fitresult(Btemp(j),Btime(j));
    temp= temp + (test(j) - fitresult(Btemp(j),Btime(j)))^2;
    TSS1= TSS1 + (test(j) - mean(j))^2;
    
end
end
Rep= 1-(temp/TSS1);
 


for (i=1:length(Btemp))
 Btime1=Btime([1:i i+1:length(Btemp)]);
 Btemp1= Btemp([1:i i+1:length(Btemp)]);
 test1= test([1:i i+1:length(Btemp)]);
%Fit: 'Dopt'.
[xData, yData, zData] = prepareSurfaceData( Btemp1, Btime1, test1 );
 
% Set up fittype and options.

ft = fittype( 'a+ b*x + c*y + d*x*y  + f*x*x', 'independent', {'x', 'y'}, 'dependent', 'z' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.StartPoint = [0.156874251597592 0.999727711922883 0.187255588886038 0.171186687811562 0.0318328463774207];
 
%% Q square
% Fit model to data.
[fitresult, gof] = fit( [xData, yData], zData, ft, opts );
q(i)= gof.rsquare;
yfit(i)=fitresult(Btemp(i),Btime(i));
PRESS= PRESS+(test(i) - yfit(i))^2;

end
PRESS;
Q2=1-(PRESS/TSS);
if Q2<0
    Q2=0;
end
Q2;
yfit;
test;

all(a,:)=[R2 Q2 Rep];


end


end


