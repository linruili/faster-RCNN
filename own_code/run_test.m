close all;
clear;

video_dir_list = {...
    '/data/UserData/Mingkuan/TestSet/0209_gogo_dataset/Mi4-video/testcase/part',...
    '/data/UserData/Mingkuan/TestSet/0209_gogo_dataset/Mate7-video/testcase/part',...
    '/data/UserData/Mingkuan/TestSet/0209_gogo_dataset/GoPro-video/testcase/part',...
    };

error_log_file = fopen('/home/amax/limkuan_files/MachineLearning/KeyframeSelection/log.txt', 'w');

for threshold = 0.2:0.1:0.9
    
    cache_dir_name = sprintf('cache_%.1f', threshold);
    
    for index = 1:length(video_dir_list) 
        testcase_list = dir(sprintf('%s/testcase*', video_dir_list{index}));
        for idx = 1:length(testcase_list)
            testcase_dir = sprintf('%s/%s', video_dir_list{index}, testcase_list(idx).name);
            if exist(sprintf('%s/%s', testcase_dir, cache_dir_name), 'dir')
                fprintf('Remove cache dir: %s\n', sprintf('%s/%s', testcase_dir, cache_dir_name))
                rmdir(sprintf('%s/%s', testcase_dir, cache_dir_name), 's');
            end
            
            script_faster_rcnn_video(sprintf('%s/front', testcase_dir), ...
                sprintf('%s/%s', testcase_dir, cache_dir_name), threshold);
            
            keyframe_val = unix(sprintf('/home/amax/limkuan_files/MachineLearning/KeyframeSelection/KeyframeSelection %s %.1f', ...
                testcase_dir, threshold));
            move_val = unix(sprintf('mv %s/landmark %s/landmark_%.1f', ...
                testcase_dir, testcase_dir, threshold));
            if keyframe_val ~= 0 || move_val ~= 0
                fprintf(error_log_file, 'error occur: %s %d\n', testscase_dir, threshold);
            end
            
        end
    end
    
end

fclose(error_log_file);
