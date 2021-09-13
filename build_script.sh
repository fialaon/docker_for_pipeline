#!/bin/bash

#clone Mask-RCNN
git clone https://github.com/fialaon/Mask_RCNN.git
cd Mask_RCNN
pip3 install -r requirements.txt
python3 setup.py install
cd ..

#clone Openpose-video
git clone https://github.com/fialaon/Realtime_Multi-Person_Pose_Estimation.git Openpose-video/

# clone contact-recognizer
git clone https://github.com/fialaon/contact-recognizer.git
cd contact-recognizer
wget https://www.di.ens.fr/willow/research/motionforcesfromvideo/contact-recognizer/models.tar.gz
tar -xf models.tar.gz
rm models.tar.gz

wget https://www.di.ens.fr/willow/research/motionforcesfromvideo/contact-recognizer/training_data.tar.gz
tar -xf training_data.tar.gz -C ~/contact-recognizer/data/joint_images/
rm training_data.tar.gz

cd ..
# clone HMR
git clone https://github.com/fialaon/hmr.git HMR-imagefolder-master/
cd HMR-imagefolder-master
wget https://people.eecs.berkeley.edu/~kanazawa/cachedir/hmr/models.tar.gz && tar -xf models.tar.gz
rm models.tar.gz


cd ..
# make user-data
mkdir -p user-data/raw/image_folder
mkdir user-data/full_images
echo SETUP FINISHED


