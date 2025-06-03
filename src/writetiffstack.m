function [] = writetiffstack(filepath,var,bitsPSample)
%------------------------------------------------------------------------------------------------
%write a 3D tif image with 16 or 32 bits
% INPUT:
% filepath: string containing the filepath for the image to be written
% var: 3D image
% bitPSample: either 16 or 32
%------------------------------------------------------------------------------------------------
if exist(filepath,'file')
    delete(filepath)
end
 
tifobj = Tiff(filepath,'a');
 
fprintf('writing file %s\n',filepath);
 
tifobj.setTag('ImageWidth',size(var,2));
tifobj.setTag('ImageLength',size(var,1));
tifobj.setTag('Photometric',Tiff.Photometric.MinIsBlack);
tifobj.setTag('BitsPerSample',bitsPSample);
tifobj.setTag('SampleFormat',Tiff.SampleFormat.Int);
tifobj.setTag('SamplesPerPixel',1);
tifobj.setTag('Compression',Tiff.Compression.None);
tifobj.setTag('PlanarConfiguration',Tiff.PlanarConfiguration.Chunky);
 
for framenum = 1:size(var,3)
 
tifobj.setTag('ImageWidth',size(var,2));
tifobj.setTag('ImageLength',size(var,1));
tifobj.setTag('Photometric',Tiff.Photometric.MinIsBlack);
tifobj.setTag('BitsPerSample',bitsPSample);
tifobj.setTag('SampleFormat',Tiff.SampleFormat.Int);
tifobj.setTag('SamplesPerPixel',1);
tifobj.setTag('Compression',Tiff.Compression.None);
tifobj.setTag('PlanarConfiguration',Tiff.PlanarConfiguration.Chunky);
 
if bitsPSample==16
    tifobj.write(int16(var(:,:,framenum)));
else
    tifobj.write(int32(var(:,:,framenum)));
end
tifobj.writeDirectory()
 
end
tifobj.close;
clear;