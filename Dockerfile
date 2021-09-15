FROM continuumio/miniconda3

ENV HOME /root

WORKDIR /app

RUN conda --version

SHELL ["/bin/bash", "--login", "-c"]

# fixing errors

RUN apt-get update ##[edited]
RUN apt-get install ffmpeg libsm6 libxext6 libosmesa-dev libgl1-mesa-glx libgl1-mesa-dev -y

RUN apt-get update
RUN apt-get -y install gcc

#install VIM
RUN ["apt-get", "update"]
RUN ["apt-get", "install", "-y", "vim"]


RUN conda install git pip

#create the environment for Openpose and contact-recognizer 
COPY py3_env.yml .
RUN conda env create -f py3_env.yml


#copy those files in there
ADD contact-recognizer /app/contact-recognizer
ADD Openpose-video /app/Openpose-video

#copy HMR files there
ADD HMR-imagefolder-master /app/HMR-imagefolder-master

#install environment for HMR (yeah, ugly, but wasnt working from hmr_env)
RUN conda create --name hmr_env python=2.7
RUN echo "conda activate hmr_env" > ~/.bashrc
RUN python --version
RUN conda install _libgcc_mutex=0.1=main
RUN conda install _openmp_mutex=4.5=1_gnu
RUN conda install ca-certificates=2021.7.5=h06a4308_1
RUN conda install certifi=2020.6.20=pyhd3eb1b0_3
RUN conda install libffi=3.3=he6710b0_2
RUN conda install libgcc-ng=9.3.0=h5101ec6_17
RUN conda install libgomp=9.3.0=h5101ec6_17
RUN conda install libstdcxx-ng=9.3.0=hd4cf53a_17
RUN conda install ncurses=6.2=he6710b0_1
RUN conda install pip=19.3.1=py27_0 
RUN conda install python=2.7.18=ha1903f6_2
RUN conda install readline=8.1=h27cfd23_0
RUN conda install setuptools=44.0.0=py27_0
RUN conda install sqlite=3.36.0=hc218d9a_0
RUN conda install tk=8.6.10=hbc83047_0
RUN conda install wheel=0.36.2=pyhd3eb1b0_0
RUN conda install zlib=1.2.11=h7b6447c_3
RUN pip install absl-py==0.11.0
RUN pip install backports-functools-lru-cache==1.6.4
RUN pip install backports-weakref==1.0.post1
RUN pip install bleach==1.5.0
RUN pip install chumpy==0.70
RUN pip install cloudpickle==1.3.0
RUN pip install cycler==0.10.0
RUN pip install cython==0.29.24
RUN pip install decorator==4.4.2
RUN pip install enum34==1.1.10
RUN pip install funcsigs==1.0.2
RUN pip install h5py==2.10.0
RUN pip install html5lib==0.9999999
RUN pip install kiwisolver==1.1.0
RUN pip install markdown==3.1.1
RUN pip install matplotlib==2.2.5
RUN pip install mock==3.0.5
RUN pip install networkx==2.2
RUN pip install numpy==1.16.6
RUN pip install opencv-python==3.3.0.9
# needed for opendr
RUN conda install -c anaconda mesa-libgl-cos6-x86_64
RUN conda install -c anaconda libglu
RUN conda install -c conda-forge freeglut
RUN pip install opendr==0.77
RUN pip install pillow==6.2.2
RUN pip install protobuf==3.17.3
RUN pip install pyparsing==2.4.7
RUN pip install python-dateutil==2.8.2
RUN pip install pytz==2021.1
RUN pip install pywavelets==1.0.3
RUN pip install scikit-image==0.14.5
RUN pip install scipy==1.2.3
RUN pip install six==1.16.0
RUN pip install subprocess32==3.5.4
RUN pip install tensorflow==1.3.0
#RUN pip install tensorflow-gpu==1.3.0 - when you want to run it on gpu (tho not working for some reason)
RUN pip install tensorflow-tensorboard==0.1.8
RUN pip install werkzeug==1.0.1
RUN echo "conda deactivate" > ~/.bashrc


#create the environment for Mask-RCNN
COPY endpoints_env.yml .
RUN conda env create -f endpoints_env.yml
RUN conda init

#copy Mask_RCNN files
ADD Mask_RCNN /app/Mask_RCNN

#copy scripts
ADD check_res.py /app/  
ADD init_script.sh /app/

#add user folder
ADD user-data /app/user-data