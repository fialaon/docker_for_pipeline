# BASE FOLDER for building Docker or Singularity container for the pipeline
This is the base folder, it contains conda environments, basic scripts, readmes. However, it doesn't contain folders with contact-recognizer, Openpose, MaskRCNN and HMR, because those folders are too large. I've created an script, which will download and set up the missing folders from github. To launch that script just run this command:

    source build_script.sh

Then you should have all 4 folders in this one and everything should be set up in order for you to work on the docker image.