function []=EEGDisplayAllPSD(data,data2,f,chlocs)

Th=[chlocs(:).theta];
Rd=[chlocs(:).radius];
Th = pi/180*Th;     
[x,y] = pol2cart(Th,Rd);
rotate = 3*pi/2;
allcoords = (y + x*sqrt(-1))*exp(sqrt(-1)*rotate);
w=0.12;
he=0.12;
x = imag(allcoords);
y = real(allcoords);
x=(1-(x-min(x)));
x=(x-min(x));
x=x/max(x); 
y=(y-min(y));
y=y/max(y);
y=y/(1+2*he)+he/2;
x=x/(1+2*w)+w/2;

chlabels={chlocs(:).labels};

hf=figure('NumberTitle','off','units','normalized','outerposition',[0 0 1 1]);
scrsz=get(0,'screensize');
set(hf,'units','pixels')
set(0,'units','pixels')
set(hf,'Name','');
clf;
set(hf,'color',[0.7 0.7 0.7]);

k=0;
for i=1:length(chlabels)
    k=k+1;
    h(k)=axes('position',[x(i) y(i) w he],...
        'ycolor',[0 0 0],...
        'xcolor',[0 0 0],...
        'ydir','normal',...
        'xlim',[f(1) f(end)],...
        'visible','on','tag',chlabels{i});
    set(findall(gca, 'type', 'text'), 'visible', 'on');
    plot(f,10*log10(data(i,:)), 'r', 'LineWidth', 1.5)
    hold on
    plot(f,10*log10(data2(i,:)), 'b', 'LineWidth', 1.5)
    hold off
    Y(i,:)=ylim;
    text(h(k),28,25,chlabels{i},'FontWeight','Bold','FontSize', 10,'HorizontalAlignment','right','VerticalAlignment','top')
    set(h(k),'Visible','on','xlim',[f(1) f(end)],'ycolor',[0 0 0],'xcolor',[0 0 0])
end
axH = findall(gcf,'type','axes');
set(axH, 'ylim', [min(Y(:,1)) max(Y(:,2))])
atx = findall(gcf,'type','text');
set(atx,'Position',[28,max(Y(:,2))-5,0])
% set(axH, 'ylim', [-20 30])