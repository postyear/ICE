function [pred] = f_main_PCC_weka_svm(train_arff, test_arff, ...
    rw_netF_prefix, n_models)
%
if ~ismac() % if not on my mac, On CBI
    pa = '';
else % if on my Macbook
    pa = ['/Volumes/Macintosh_HD/Users/zhengao/bio/3_ensembF/2_ref/',...
    'Jamiul_code/PCC_code_and_test_data/'];
end

java_class_name = 'PCC_svm';
command = ['java -cp ',pa,'weka.jar:',pa,'jmatio.jar:',pa,...
    ' ',java_class_name,'  ',train_arff, ' ', test_arff, ' ',...
    rw_netF_prefix, ' ', f_arr2str(n_models, '-')];

command,
[~, result] = system(command),

pred = load([test_arff(1:end-4), 'txt']);


end

