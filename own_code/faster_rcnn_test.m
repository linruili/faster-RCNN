 function prob_full_name = faster_rcnn_test(image_full_path, rcnn_counter, threshold, opts, proposal_detection_model, rpn_net, fast_rcnn_net)
 
 %% -------------------- TESTING --------------------
running_time = [];

im_name= '';
[pathstr, name, ext] = fileparts(image_full_path);


testcase_dir = getPrePath(pathstr);
result_dir = fullfile(testcase_dir, 'rcnn_result');
sub_result_dir = sprintf('%s/%d', result_dir, rcnn_counter);

im_name = sprintf('%03d.jpg',  rcnn_counter);

if ~exist(sub_result_dir,'dir')
    mkdir(sub_result_dir);
end

prob_full_name = sprintf('%s/prob.txt', sub_result_dir);
prob_file_fid = fopen(prob_full_name, 'w');

img = imread(fullfile(image_full_path));
result_count = 0;

if opts.use_gpu
    im = gpuArray(img);
end

% test proposal
th = tic();
[boxes, scores]             = proposal_im_detect(proposal_detection_model.conf_proposal, rpn_net, im);
t_proposal = toc(th);
th = tic();
aboxes                      = boxes_filter([boxes, scores], opts.per_nms_topN, opts.nms_overlap_thres, opts.after_nms_topN, opts.use_gpu);
t_nms = toc(th);

% test detection
th = tic();
if proposal_detection_model.is_share_feature
    [boxes, scores]             = fast_rcnn_conv_feat_detect(proposal_detection_model.conf_detection, fast_rcnn_net, im, ...
        rpn_net.blobs(proposal_detection_model.last_shared_output_blob_name), ...
        aboxes(:, 1:4), opts.after_nms_topN);
else
    [boxes, scores]             = fast_rcnn_im_detect(proposal_detection_model.conf_detection, fast_rcnn_net, im, ...
        aboxes(:, 1:4), opts.after_nms_topN);
end
t_detection = toc(th);


fprintf('%s (%dx%d): time %.3fs (resize+conv+proposal: %.3fs, nms+regionwise: %.3fs)\n', im_name, ...
    size(im, 2), size(im, 1), t_proposal + t_nms + t_detection, t_proposal, t_nms+t_detection);
running_time(end+1) = t_proposal + t_nms + t_detection;

% visualize
classes = proposal_detection_model.classes;
boxes_cell = cell(length(classes), 1);
% thres = 0.6;
%%%%%%%%%%%%%%% To Modify  %%%%%%%%%%%%%%%%
thres = threshold;

for i = 1:length(boxes_cell)
    boxes_cell{i} = [boxes(:, (1+(i-1)*4):(i*4)), scores(:, i)];
    boxes_cell{i} = boxes_cell{i}(nms(boxes_cell{i}, 0.3), :);

    I = boxes_cell{i}(:, 5) >= thres;
    boxes_cell{i} = boxes_cell{i}(I, :);
end
%     figure(j);
%     showboxes(im, boxes_cell, classes, 'voc');
box_info = boxes_cell{1, 1}(:, 1:4);
box_info = [box_info(:, 1:2), box_info(:, 3) - box_info(:, 1), ...
    box_info(:, 4) - box_info(:, 2)];
for i = 1:size(box_info, 1)
    crop_img = imcrop(img, box_info(i, :));
    region_full_name = sprintf('%s/%02d.jpg', sub_result_dir, result_count);
    imwrite(crop_img, region_full_name);
    fprintf(prob_file_fid, '%s %s %f %f %f %f %f\n', im_name, ...
        region_full_name , boxes_cell{1, 1}(i, 5), boxes_cell{1, 1}(i, 1:4));
    result_count = result_count + 1;
end

%pause(0.1);
fclose(prob_file_fid);

fprintf('mean time: %.3fs\n', mean(running_time));

%caffe.reset_all(); 
%clear mex;

 end