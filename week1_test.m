%%2025 09 16 week1 DIP 课上草稿
clc; clear; close all;

indir='E:\AppCache\MATLAB\DIP\SSTdata\';
ifname='AQUA_MODIS.20020701_20230731.L3m.MC.SST.sst.4km.nc';

ncdisp([indir ifname]);

var='sst';
sst=ncread([indir ifname],var);
%读经纬度，二维化
var='lat';
lat=ncread([indir ifname],var);
var='lon';
lon=ncread([indir ifname],var);

%经纬度网格化
longrid=repmat(lon,1,size(lat,1));
latgrid=repmat(lat',size(lon,1),1);

% %% 画全球的图
% figure
% pcolor(longrid,latgrid,sst);
% shading flat;
% colorbar;


%m_map画图
latmin=-90;
latmax=90;
lonmin=-180;
lonmax=280;

figure
m_proj('Equidistant Cylindrical', 'long', [lonmin,lonmax], ...
    'lat', [latmin,latmax]);
m_pcolor(longrid, latgrid, sst);
shading flat;
colorbar;
m_grid;      %添加经纬度网格

%保存图像
drawnow;  % 确保图形窗口已更新
print(gcf,'-dpng','-r200',[indir 'sst.png']);      

%%取小块范围
latmin0=28;
latmax0=34;
lonmin0=120;
lonmax0=125;
ind1=find(lon>=lonmin0 & lon<=lonmax0);
ind2=find(lat>=latmin0 & lat<=latmax0);

latgrid_sub=latgrid(ind1, ind2);
longrid_sub=longrid(ind1, ind2);
sst_sub=sst(ind1, ind2);

figure
m_proj('Equidistant Cylindrical', 'long', [lonmin0,lonmax0], ...
    'lat', [latmin0,latmax0]);
m_pcolor(longrid, latgrid, sst);
shading flat;
colorbar
m_grid;

% m_coast;

%高精度岸线
m_gshhs_i;
drawnow;  % 确保图形窗口已更新
print(gcf,'-dpng','-r200',[indir 'sst_sub.png']);
