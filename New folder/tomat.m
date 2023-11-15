function varargout = tomat(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @tomat_OpeningFcn, ...
    'gui_OutputFcn',  @tomat_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end
 
if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
function tomat_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
guidata(hObject, handles);
movegui(hObject,'center');

function varargout = tomat_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;

function pushbutton6_Callback(hObject, eventdata, handles)
Img = handles.Img;
Img_bw = handles.Img_bw;
ciri_bentuk = handles.ciri_bentuk;
Img_gray = rgb2gray(Img);
Img_gray(~Img_bw) = 0;
axes(handles.axes5)
imshow(Img_gray)
title('Citra Grayscale')
pixel_dist = 1;
GLCM = graycomatrix(Img_gray,'Offset',[0 pixel_dist; -pixel_dist pixel_dist; -pixel_dist 0; -pixel_dist -pixel_dist]);
stats = graycoprops(GLCM,{'contrast','correlation','energy','homogeneity'});
Contrast = stats.Contrast;
Correlation = stats.Correlation;
Energy = stats.Energy;
Homogeneity = stats.Homogeneity;
ciri_total = cell(6,2);
ciri_total{1,1} = ciri_bentuk{1,1};
ciri_total{1,2} = ciri_bentuk{1,2};
ciri_total{2,1} = ciri_bentuk{2,1};
ciri_total{2,2} = ciri_bentuk{2,2};
ciri_total{3,1} = 'Contrast';
ciri_total{4,1} = 'Correlation';
ciri_total{5,1} = 'Energy';
ciri_total{6,1} = 'Homogeneity';
ciri_total{3,2} = num2str(Contrast);
ciri_total{4,2} = num2str(Correlation);
ciri_total{5,2} = num2str(Energy);
ciri_total{6,2} = num2str(Homogeneity);
 
handles.ciri_total = ciri_total;
guidata(hObject, handles)
 
set(handles.text2,'String','Ekstraksi Ciri')
set(handles.uitable1,'Data',ciri_total,'RowName',1:6)
function edit1_Callback(hObject, eventdata, handles)

function edit1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function pushbutton4_Callback(hObject, eventdata, handles)
Img = handles.Img;
lab = handles.lab;

ab = double(lab(:,:,2:3));
nrows = size(ab,1);
ncols = size(ab,2);
ab = reshape(ab,nrows*ncols,2);

nColors = 2;
[cluster_idx, ~] = kmeans(ab, nColors, 'distance', 'sqEuclidean', 'Replicates',3);

pixel_labels = reshape(cluster_idx, nrows, ncols);

segmented_images = cell(1, nColors);
rgb_label = repmat(pixel_labels, [1, 1, 3]);

for k = 1:nColors
    color = Img;
    color(rgb_label ~= k) = 0;
    segmented_images{k} = color;
end

area_cluster1 = sum(pixel_labels(:) == 1);
area_cluster2 = sum(pixel_labels(:) == 2);

[~, cluster_min] = min([area_cluster1, area_cluster2]);

Img_bw = (pixel_labels == cluster_min);
Img_bw = imfill(Img_bw, 'holes');
Img_bw = bwareaopen(Img_bw, 50);

tomat = Img;
R = tomat(:, :, 1);
G = tomat(:, :, 2);
B = tomat(:, :, 3);
R(~Img_bw) = 0;
G(~Img_bw) = 0;
B(~Img_bw) = 0;
tomat_rgb = cat(3, R, G, B);
axes(handles.axes3);
imshow(tomat_rgb);
title('Citra Hasil Segmentasi');

handles.Img_bw = Img_bw;
guidata(hObject, handles);

function pushbutton5_Callback(hObject, eventdata, handles)
    Img_bw = handles.Img_bw;
    axes(handles.axes4)
    imshow(Img_bw)
    title('Citra biner');
    stats = regionprops(Img_bw,'Area','Perimeter','Eccentricity');
    area = stats.Area;
    perimeter = stats.Perimeter;
    metric = 4*pi*area/(perimeter^2);
    eccentricity = stats.Eccentricity;
    ciri_bentuk = cell(2,2);
    ciri_bentuk{1,1} = 'Metric';
    ciri_bentuk{2,1} = 'Eccentricity';
    ciri_bentuk{1,2} = num2str(metric);
    ciri_bentuk{2,2} = num2str(eccentricity);
    handles.ciri_bentuk = ciri_bentuk;
    guidata(hObject, handles)
    set(handles.text2,'String','Ekstraksi Ciri')
    set(handles.uitable1,'Data',ciri_bentuk,'RowName',1:2)

function pushbutton2_Callback(hObject, eventdata, handles)
axes(handles.axes1)
cla reset
set(gca,'XTick',[])
set(gca,'YTick',[])
 
axes(handles.axes2)
cla reset
set(gca,'XTick',[])
set(gca,'YTick',[])
 
axes(handles.axes3)
cla reset
set(gca,'XTick',[])
set(gca,'YTick',[])
 
axes(handles.axes4)
cla reset
set(gca,'XTick',[])
set(gca,'YTick',[])
 
axes(handles.axes5)
cla reset
set(gca,'XTick',[])
set(gca,'YTick',[]) 
set(handles.text2,'String',[])
set(handles.uitable1,'Data',[])
set(handles.edit1,'String',[])

function pushbutton1_Callback(hObject, eventdata, handles)
[filename,pathname] = uigetfile('*.jpg');
 
if ~isequal(filename,0)
    Img = imread(fullfile(pathname,filename));
    axes(handles.axes1)
    imshow(Img)
    title('Citra RGB')
else
    return
end
 
handles.Img = Img;
guidata(hObject, handles)

function pushbutton7_Callback(hObject, eventdata, handles)
load ciri_database
ciri_total = handles.ciri_total;
ciri = zeros(1,6);
for i = 1:6
    ciri(i) = str2double(ciri_total{i,2});
end
 
[num,~] = size(ciri_database);
 
dist = zeros(1,num);
for n = 1:num
    data_base = ciri_database(n,:);
    jarak = sum((data_base-ciri).^2).^0.5;
    dist(n) = jarak;
end
 
[~,id] = min(dist);
 
if isempty(id)
    set(handles.edit1,'String','Unknown')
else
    switch id
        case 1
            tingkat = 'Tomat Hijau';
        case 2
            tingkat = 'Tomat Hijau';
        case 3
            tingkat = 'Tomat Hijau';
        case 4
            tingkat = 'Tomat Hijau';
        case 5
            tingkat = 'Tomat Merah';
        case 6
            tingkat = 'Tomat Merah';
        case 7
            tingkat = 'Tomat Merah';
        case 8
            tingkat = 'Tomat Merah';
    end
    set(handles.edit1,'String',tingkat)
end
function pushbutton3_Callback(hObject, eventdata, handles)
Img = handles.Img;

cform = makecform('srgb2lab');
lab = applycform(Img,cform);
axes(handles.axes2)
imshow(lab)
title('Citra L*a*b');
 
handles.lab = lab;
guidata(hObject, handles)
