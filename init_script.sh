#!/bin/bash

# initialization of conda
conda init bash
. ~/.bashrc

###########################################################################
#############********************VARIABLES********************#############
tool=spade
image_folder=image_folder
video_number_list='1'        
echo tool:  ${tool}
echo image_folder: ${image_folder}

###########################################################################
#############*************CONTACT-RECOGNIZER INIT*************#############
data=$(echo /app/user-data)

mkdir ${data}/full_images/${image_folder}
cp -r ${data}/raw/${image_folder}/* ${data}/full_images/${image_folder}

conda activate py3

###########################################################################
#############****************RESOLUTION CHECKING**************#############
cp /app/check_res.py ${data}/full_images/${image_folder}/
cd ${data}/full_images/${image_folder}/

python3 check_res.py
rm check_res.py

ret=`echo "$?"`
if (($ret==0)) ; then
    ###########################################################################
    #############**********CONTACT-RECOGNIZER + OPENPOSE**********#############

    
    cd /app/contact-recognizer
    python create_data/create_data_info.py ${data}/full_images/${image_folder} --image_types="png,jpg" --save_info
    
    cd /app/Openpose-video/testing/python
    img_dir=${data}/full_images/${image_folder}
    vis_j2d=${data}/openpose/${image_folder}
    path_j2d=${data}/openpose/${image_folder}/Openpose-video.pkl

    python run_imagefolder.py ${img_dir} ${vis_j2d} ${path_j2d} --save-after-each-iteration 

    cd /app/contact-recognizer
    python create_data/annotation_tool.py ${img_dir} ${vis_j2d} ${path_j2d}

    echo Skipping annotation

    save_dir=${data}/joint_images/${image_folder}
    crop_sizes=180,120
    joint_names=neck,hands,knees,soles,toes 

    python create_data/create_data.py ${img_dir} ${save_dir} ${path_j2d} --crop-sizes=${crop_sizes} --joint-names=${joint_names}

    cd /app/contact-recognizer
    ./scripts/run_demo.sh

    ###########################################################################
    #############***********************HMR***********************#############
    conda activate hmr_env

    img_dir=${data}/full_images/${image_folder}
    vis_dir=${data}/HMR
    openpose_path=${data}/openpose/${image_folder}/Openpose-video.pkl
    save_path=${data}/HMR/HMR.pkl

    cd /app/HMR-imagefolder-master/

    python run_imagefolder.py --image_folder ${img_dir} --vis_folder ${vis_dir} --openpose_path ${openpose_path} --save_path ${save_path} --save_after_each_iteration True

    ###########################################################################
    #############********************ENDPOINTS********************#############
    conda activate Endpoints

    cd /app/Mask_RCNN

    python setup.py install 

    cd /app/Mask_RCNN/samples/handtools/


    rm -r /app/Mask_RCNN/samples/handtools/handtools/results/*
    rm -r /app/Mask_RCNN/samples/handtools/handtools/frames/*


    cp -r ${data}/raw/${image_folder}/* /app/Mask_RCNN/samples/handtools/handtools/frames/
    cp -r ${data}/openpose/${image_folder}/* /app/Mask_RCNN/samples/handtools/handtools/openpose/
    cp -r /app/user-data/openpose/${image_folder}/Openpose-video.pkl /app/Mask_RCNN/samples/handtools/handtools/openpose/handtools_openpose.pkl

    python handtools_ijcv_mrcnn_inference.py --class_label=${tool} --video_number_list=${video_number_list}

    python handtools_ijcv_recognize_endpoints.py --class_label=${tool} --video_number_list=${video_number_list}

    ###########################################################################
    #############*****************FORMING RESULTS*****************#############

    conda activate base
    cd /app
    rm -r /app/results

    #############***************contact recognizer****************#############
    mkdir /app/results
    mkdir /app/results/contact-recognizer
    cp /app/user-data/full_images/${image_folder}/contact_states_annotation.pkl /app/results/contact-recognizer/contact-recognizer.pkl

    #############**********************HMR************************#############
    mkdir results/HMR
    cp /app/user-data/HMR/HMR.pkl results/HMR/

    #############********************MASK RCNN********************#############
    mkdir /app/results/object_2d_endpoints
    mkdir /app/results/object_2d_endpoints/endpoints
    mkdir /app/results/object_2d_endpoints/scores

    #############********************endpoints********************#############
    cp  /app/Mask_RCNN/samples/handtools/handtools/results/*/*_endpoints_mrcnn.txt /app/results/object_2d_endpoints/endpoints/
    cd /app/results/object_2d_endpoints/endpoints

    for file in *
    do
        number=$(echo ${file//[^0-9]/})
        updated_number=$(printf '%04i' ${number})
        echo ${updated_number}
        mv ${file} /app/results/object_2d_endpoints/endpoints/${tool}_${updated_number}_endpoints.txt
    done

    #############*********************scores**********************#############
    cp /app/Mask_RCNN/samples/handtools/handtools/results/*/*_scores.txt /app/results/object_2d_endpoints/scores/
    cd /app/results/object_2d_endpoints/scores

    for file in *
    do
        number=$(echo ${file//[^0-9]/})
        updated_number=$(printf '%04i' ${number})
        echo ${updated_number}
        mv ${file} /app/results/object_2d_endpoints/scores/${tool}_${updated_number}_scores.txt
    done


    #############********************Openpose********************#############
    mkdir /app/results/Openpose-video
    cp /app/user-data/openpose/${image_folder}/Openpose-video.pkl /app/results/Openpose-video/

    #############*********************videos*********************#############
    mkdir /app/results/videos

    for folder in /app/user-data/raw/image_folder/*
    do
    	ffmpeg -pattern_type  glob -i ${folder}/"*.png" ${folder}.mp4
        mv ${folder}.mp4 /app/results/videos
    done

    cd /app

    ###########################################################################
    ###########################################################################
else
    echo ERROR: Wrong resolution
fi
