# BASE FOLDER for building Docker or Singularity container for the pipeline
This is the base folder, it contains conda environments, basic scripts, readmes. However, it doesn't contain folders with contact-recognizer, Openpose, MaskRCNN and HMR, because those folders are too large. I've created an script, which will download and set up the missing folders from github. To launch that script just run this command:

1.        source build_script.sh

Then you should have all 4 folders in this one and everything should be set up in order for you to work on the docker image.

# Building docker image

When you are finished working with it, you have made your changes (either in files, folders, dockerfile, scripts, it doesn't really matter), you will need to set up a profile on docker hub. Once you have your docker hub profile created you will click on create repository and you will create, and name it somehow. Then you will build your docker image (you have to be in terminal where the Dockerfile exists):

1.        docker build --tag <your_username>/<name_of_repository>:<tag> .

Let's say my name on dockerhub is jamesbond and I want the repository to be named shake_shake, I have built new repository in the image so I will tag my image as new_rep, my command then will look like this:

          docker build --tag jamesbond/shake_shake:new_rep .

If you want to run the docker image, just to test it before conversion to singularity just use this command:

2.        docker run -tid --name <custom_name> <your_username>/<name_of_repository>:<tag>

Once again example, names as previous, but now I want the running docker image be named as first_try. (If you don't give it the --name tag it will just name it somehow according to docker regulations - the name then can be found with the command: $ docker ps). My command then looks like this:
          docker run -tid --name first_try jamesbond/shake_shake:new_rep

it will run in detached version, if you want to see the terminal inside the docker just use:

3.        docker exec -ti <custom_name> bash

My command as James Bond's will then look like this:

          docker exec -ti first_try bash

Once you are sure, that the version you've created has met your expectations, you need to push it on docker hub with the command:

4.        docker push <your_username>/<name_of_repository>:tag

That will push the image into your repository, it can be found there and you can work with it from there.
Example command would look like this:

            docker push jamesbond/shake_shake:new_rep

# Converting to singularity

Now there's the time, where you want to convert it to singularity. On cluster you can use our pipeline_cluster.sh script (to be found in this folder). You need to change just the 26th line, where instead of fialaon/pipeline you will write <your_username>/<name_of_repository>:<tag>. If you are not using this script or you are not on cluster, the command you are looking for is:

5.         singularity build --sandbox <you_desired_name> docker://<your_username>/<name_of_repository>:<tag>

Example command:

           singularity build --sandbox pipeline/ docker://jamesbond/shake_shake:new_rep

After this command is performed, you will have writable container built (and you can continue with README_forcluster.md).