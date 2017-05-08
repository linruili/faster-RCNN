close all;
clear;
clc;


%run('/home/HAVIL/faster_rcnn/own_code/start_faster_rcnn.m');

image_full_path1 = '/home/TestSet/0209_gogo_dataset/GoPro-vedio/part/testcase1/front/011.jpg';
image_full_path2 = '/home/TestSet/0209_gogo_dataset/GoPro-vedio/part/testcase2/front/011.jpg';

threshold = 0.2;
rcnn_counter = 1;
[opts, proposal_detection_model, rpn_net, fast_rcnn_net] = start_faster_rcnn();
faster_rcnn_test(image_full_path1, rcnn_counter, threshold, opts, proposal_detection_model, rpn_net, fast_rcnn_net);
faster_rcnn_test(image_full_path2, rcnn_counter, threshold, opts, proposal_detection_model, rpn_net, fast_rcnn_net);


    

