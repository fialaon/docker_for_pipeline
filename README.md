# Singularity container for pipeline

This is an Singularity container for pipeline consisting of contact recognizer, openpose video,  HMR and Mask RCNN.

First of all, when you want to build an writable container of singularity run script pipeline_cluster.sh with command:

    sbatch pipeline_cluster.sh

that will create a sandbox folder (by default with the name pipeline/).

Then you need to start an interactive job. For our purposes use this command:

    srun --cpus-per-task=2 --gres=gpu:4 --mem=16G --time=23:59:00 --partition gpu --pty --exclude=node-12,dgx-2,dgx-3,dgx-4,dgx-5 bash

that should give you an job with enough time. 

Once this job is done. You should have your video already prepared in frames 400x600 in following structure:

    user-data   / raw           / image_folder  / <toolname>_<number>  / *.png or *.jpg
                / full_images   /

toolname should be shovel, hammer, scythe etc., number should start from 1 and continue.

If you have the sandbox container prepared (and you are still in an interactive job on cluster), launch it with command:

    singularity run --nv --writable <name_of_sandbox_folder>/

Sandbox option creates a directory, one disadvantage of this is that every change is solid and can't be undone. That means, if you change something, it will stay there, it's not like docker. So if you need, just build the sandbox once again and destroy the old one.

After that copy your folder named "user-data" to /app with command:

    scp -r user-data/ /app

Then go to /app

    cd /app

and check the parameters in init_script.sh. There's editor VIM installed in singularity, so that should be easy. You should be changing two things, once is variable called 'tool', by origin there's written 'spade', so if you are using the pipeline for different tool, change it. The other thing to change is video_number_list, that is simply string of numbers (same as when you were naming your folders where you have put the images), separated by comma. So for example in user-data/raw/image_folder you will have three folders - spade_1, spade_2, spade_3 - then the video_number_list will be '1,2,3'.

Then just launch the scripts and let it do its job.

    source init_script.sh

After the script is done running, every result should be in folder /app in following structure:

    results
        contact-recognizer
            contact-recognizer.pkl
        HMR
            HMR.pkl
        object_2d_endpoints
            endpoints
                tool_0001_endpoints.txt
                ...
            scores
                tool_0001_scores.txt
                ...
        Openpose-video
            Openpose-video.pkl
        videos
            tool_1.mp4
            ...

Copy that folder, where you want

    scp -r /app/results/ <desired_destination>


# Common errors and solutions
At the start, while running Openpose there might be this error:

  File "run_imagefolder.py", line 93, in <module>
    results = main(image_paths, vis_dir, save_path=None)
  File "/app/Openpose-video/testing/python/main.py", line 83, in main
    heatmap_avg = heatmap_avg + heatmap / len(multiplier)
    ValueError: operands could not be broadcast together with shapes (400,600,19) (400,600,38) 


if you see this, it's probably because you have too many apps and processes running on your computer/laptop. Just close as much procceses as possible and try to run it once again.

 
# pipeline
