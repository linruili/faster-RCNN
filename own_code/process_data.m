close all;
clear;

annotations_template = strcat('<annotation>\n', ...
    '\t<folder>signboard</folder>\n', ...
    '\t<filename>%06d.jpg</filename>\n', ...
    '\t<source>\n', ...
    '\t\t<database>My Database</database>\n', ...
    '\t\t<annotation>VOC20007</annotation>\n', ...
    '\t\t<image>flickr</image>\n', ...
    '\t\t<flickrid>NULL</flickrid>\n', ...
    '\t</source>\n', ...
    '\t<onwer>\n', ...
    '\t\t<flickrid>NULL</flickrid>\n', ...
    '\t\t<name>SmartYi</name>\n', ...
    '\t</onwer>\n', ...
    '\t<size>\n', ...
    '\t\t<width>2000</width>\n', ...
    '\t\t<height>1500</height>\n', ...
    '\t\t<depth>3</depth>\n', ...
    '\t</size>\n', ...
    '\t<segmented>0</segmented>\n');

object_template = strcat('\t<object>\n', ...
    '\t\t<name>signboard</name>\n', ...
    '\t\t<pose>Unspecified</pose>\n', ...
    '\t\t<truncated>0</truncated>\n', ...
    '\t\t<difficult>0</difficult>\n', ...
    '\t\t<bndbox>\n', ...
    '\t\t\t<xmin>%d</xmin>\n', ...
    '\t\t\t<ymin>%d</ymin>\n', ...
    '\t\t\t<xmax>%d</xmax>\n', ...
    '\t\t\t<ymax>%d</ymax>\n', ...
    '\t\t</bndbox>\n', ...
    '\t</object>\n');

annotation_final = '</annotation>';


output_dir = 'datasets/VOCdevkit2007/VOC2007/';
train_val_dir = '/home/amax/limkuan_files/MachineLearning/data_testset/ratio_0.9_cur/train';
test_dir = '/home/amax/limkuan_files/MachineLearning/data_testset/ratio_0.9_cur/test';

annotation_dir = sprintf('%s/Annotations/', output_dir);
imageset_dir = sprintf('%s/ImageSets/Main', output_dir);
image_dir = sprintf('%s/JPEGImages', output_dir);
mkdir(annotation_dir);
mkdir(imageset_dir);
mkdir(image_dir);

store_num = 55;

train_val_ratio = 0.9;

% process train and val dataset
train_val_list_fid = fopen(sprintf('%s/trainval.txt', imageset_dir), 'w');
train_list_fid = fopen(sprintf('%s/train.txt', imageset_dir), 'w');
val_list_fid = fopen(sprintf('%s/val.txt', imageset_dir), 'w');
test_list_fid = fopen(sprintf('%s/test.txt', imageset_dir), 'w');

image_count = 0;

for store_index = 1:store_num
    image_set = imageSet(sprintf('%s/JPEGImages/%d', train_val_dir, store_index));
    for image_index = 1:image_set.Count
        
        image_path = image_set.ImageLocation{image_index};
        
        fprintf('Processing image %s\n', image_path);
        
        [path, name, ext] = fileparts(image_path);
        
        image_count = image_count + 1;
        dest_image_dir = sprintf('%s/%06d.jpg', image_dir, image_count);
        % process regions
        annotations_fid = fopen(sprintf('%s/Annotations/%d/%s.txt', ...
            train_val_dir, store_index, name));
        annotations = textscan(annotations_fid, '%d %d %d %d %d %s');
        fclose(annotations_fid);
        
        region_pos = [annotations{1, 1} annotations{1, 2} ...
            annotations{1, 3} annotations{1, 4}];
        region_id = annotations{1, 5};
        
        if isempty(region_id)
            continue;
        end
        
        fprintf(train_val_list_fid, '%06d\n', image_count);
        if rand > train_val_ratio
            fprintf(val_list_fid, '%06d\n', image_count);
        else
            fprintf(train_list_fid, '%06d\n', image_count);
        end
        
        eval(sprintf('!cp %s %s', image_path, dest_image_dir));
        
        dest_annotation_fid = fopen(sprintf('%s/%06d.xml', ...
            annotation_dir, image_count), 'w');
        
        fprintf(dest_annotation_fid, annotations_template, image_count);

        for region_index = 1:length(region_id)
            fprintf(dest_annotation_fid, object_template, region_pos(region_index, :));
        end
        
        fprintf(dest_annotation_fid, annotation_final);
        fclose(dest_annotation_fid);
    end
    
end

% process test dir
for store_index = 1:store_num
    image_set = imageSet(sprintf('%s/JPEGImages/%d', test_dir, store_index));
    for image_index = 1:image_set.Count
        
        image_path = image_set.ImageLocation{image_index};
        
        fprintf('Processing image %s\n', image_path);
        
        [path, name, ext] = fileparts(image_path);
        
        image_count = image_count + 1;
        
        dest_image_dir = sprintf('%s/%06d.jpg', image_dir, image_count);
        
        % process regions
        annotations_fid = fopen(sprintf('%s/Annotations/%d/%s.txt', ...
            test_dir, store_index, name));
        annotations = textscan(annotations_fid, '%d %d %d %d %d %s');
        fclose(annotations_fid);
        
        region_pos = [annotations{1, 1} annotations{1, 2} ...
            annotations{1, 3} annotations{1, 4}];
        region_id = annotations{1, 5};
        
        if isempty(region_id)
            continue;
        end
        
        fprintf(test_list_fid, '%06d\n', image_count);
        
        eval(sprintf('!cp %s %s', image_path, dest_image_dir));
        
        dest_annotation_fid = fopen(sprintf('%s/%06d.xml', ...
            annotation_dir, image_count), 'w');
        fprintf(dest_annotation_fid, annotations_template, image_count);
        for region_index = 1:length(region_id)
            fprintf(dest_annotation_fid, object_template, region_pos(region_index, :));
        end
        
        fprintf(dest_annotation_fid, annotation_final);
        fclose(dest_annotation_fid);
    end
    
end

fclose(train_val_list_fid);
fclose(train_list_fid);
fclose(val_list_fid);
fclose(test_list_fid);

