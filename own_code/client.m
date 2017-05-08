close all;
clear all;
clc;

t = tcpip('127.0.0.1',3333);
fopen(t);
pause(1);

threshold = 0.2;
[opts, proposal_detection_model, rpn_net, fast_rcnn_net] = start_faster_rcnn();

while(true)
    while(t.BytesAvailable==0)
        pause(0.01);
    end
    DataReceived= char( fread(t,t.BytesAvailable) );
    paras =DataReceived';
    
    %传入的参数之间用#分割 
    paras = strsplit(paras, '#');
    image_full_path = paras{1};
    rcnn_counter = str2double( paras{2} );
    fprintf('rcnn_counter = %d\n',rcnn_counter);
    timerVal = tic;
    DataToSend = faster_rcnn_test(image_full_path, rcnn_counter, threshold, opts, proposal_detection_model, rpn_net, fast_rcnn_net);
    time = toc(timerVal);
    fprintf('RCNN run time = %f\n',time); 
    fwrite(t,DataToSend);
end

fclose(t);
delete(t);
clear t;