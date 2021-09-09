import os
import sys
import cv2 as cv
path = os.getcwd()
for folder in os.listdir(path):
    if folder == "check_res.py": #for obvious reasons
        continue
    for img in os.listdir(os.path.join(path,folder)):
        res_img = cv.imread(path + '/' + folder + '/' + img)
        height = res_img.shape[0]
        width = res_img.shape[1]
        if height != 400 or width != 600:
            sys.exit(1)
sys.exit(0) # This is the output if everything goes right