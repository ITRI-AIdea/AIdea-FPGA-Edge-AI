# AIdea FPGA Edge AI – AOI Tutorial #

### This tutorial shows you how to generate a baseline .xmodel for AIdea AOI contest on FPGA(Xilinx Alveo U50LV10E) using codes modified from Xilinx Vitis-AI-Tutorials 08-tf2_flow by Aidea members. We hope that by following these steps, you could become more familiar with Vitis-AI and the competition.     

## Step 0: Meet Prerequisite 

Follow the instructions of VitisAI_TF2-Tutorial.pdf to build Vitis-AI CPU or GPU docker. You can run the example in VitisAI_TF2-Tutorial.pdf to make sure your Vitis-AI CPU or GPU docker is working and can train, quantize, and compile.

Download [VitisAI_TF2-Tutorial.pdf](http://buckets.aidea-web.tw/VitisAI_TF2_Tutorial.pdf)


## Step 1: Clone Repo

Enter Vitis-AI CPU or GPU docker container and then download this repository at the directory that you want. (eg. workspace)
```
$ git clone https://github.com/ITRI-AIdea/AIdea-FPGA-Edge-AI.git
```
## Step 2: Download Datasets

Enter AIdea-FPGA-Edge-AI directory. Use AIdea CLI tool to download training images and label file (train_images.zip and train.csv).
```
$ cd AIdea-FPGA-Edge-AI
```
AIdea CLI tool usage: https://github.com/ITRI-AIdea/aidea-cli

## Step 3: Unzip Datasets

Unzip the downloaded train_images.zip
```
$ unzip train_images.zip
```
## Step 4: Label Datasets

Execute aoi_rename.py to rename and label the training images.
```
$ python3 aoi_rename.py
```
## Step 5: Prepare Datasets

Create dataset/train directory to store training images. Copy the labeled training images to the dataset/train directory.
```
$ mkdir dataset
$ cd dataset
$ mkdir train
$ cd ..
$ cp -r train_images/. dataset/train/
```
## Step 6: Activate Environment

Activate the Tensorflow2 python virtual environment (you should see the prompt change to indicate that the environment is active)
```	
$ conda activate vitis-ai-tensorflow2
```
## Step 7: Convert Images

The images_to_tfrec.py will do the following: Convert the images in PNG format into TFRecord format to speed up training. Split the images into train and test datasets, ensuring the balance between classes. The TFRecord files(.tfrecord) will be saved into tfrecords directory.
```
$ python -u images_to_tfrec.py 2>&1 | tee tfrec.log
```
## Step 8: Train Model

Training uses the following three files: train.py, dataset_utils.py, and customcnn.py. It will generate a 32-bits floating-point model saved in .h5 format which could be used for quantization in the next step.
```
$ python -u train.py 2>&1 | tee train.log
```
## Step 9: Quantize Model

Xilinx FPGA cards execute models with parameters in integer format. Thus, we need to transfer our floating-point models into fix-point models. This process is known as quantization and can be achieved by using Vitis-AI Quantizer.
```
$ python -u quantize.py --evaluate 2>&1 | tee quantize.log
```
## Step 10: Compile Model

Vitis-AI Compiler can compile .xmodel which contains instructions and data to be executed by FPGA cards. Note that we need to specify which FPGA target board we want to run inference on. In this competition, we use Xilinx Alveo U50LV10E acceleration card. The compiled .xmodel will be saved in the compiled_model directory.
```
$ source compile.sh u50lv
```
## Step 11: Upload .xmodel

When you go to the compiled_model directory, you should see deploy.xmodel. Zip deploy.xmodel(only English letters and numbers are allowed in naming, no special character) and then use AIdea CLI tool to hand in your work.
```
$ cd compiled_model/
$ zip -r model.zip deploy.xmodel
```
AIdea CLI tool usage: https://github.com/ITRI-AIdea/aidea-cli

## Important Notices

1.	If you need helps or have questions regarding this tutorial, feel free to ask here: “paste link here”
2.	This tutorial is tested using Vitis-AI 1.4 GPU docker with compatible Nvidia GPU and CUDA support. The provided codes are tested using Tensorflow2.3. 
3.	The network used by this tutorial is pretty simple and the projected scores will not be too great. It is provided for you to get familiar with this competition. You will receive no rewards if you don’t do any modifications.
4.	**When you try to modify codes, please make sure the following requirements are met, or your submission may fail:**
> ***The size of input images: 512x512 pixels  
Input channels: 3  
.xmodel can run on Xilinx Alveo U50LV10E  
.xmodel is named as deploy.xmodel  
Submit .zip file with an arbitrary name (as long as it is composed of English letters or numbers)  
.xmodel without the leading folder and no files other than deploy.xmodel is in the zip***


## Additional Tips
1.	If you want to directly use PNG format images for training, you don’t need to use images_to_tfrec.py. Instead, you need to process images by yourself and make sure your model can accept PNG format input images.
2.	If you want to change images usage during training or quantization, you can modify functions in dataset_utils.py.
3.	If you want to design a more complex network architecture and you are ok with tensorflow2 framework, you can simply modify customcnn.py. Please noted that during scoring, both accuracy and throughput(FPS) will be considered. A more complex model will not guarantee a better score.
4.	You can use other frameworks supported by Vitis-AI such as PyTorch or Caffe to develop your work. However, different frameworks have different quauntizers that take different input files. 
5.	Since U50LV10E acceleration card has multiple DPU cores, parallel programming and the reduction of dependencies are good approaches for better throughput.
6.	It is highly encouraged to have a deeper understanding of FPGA cards or more specifically, Xilinx Alveo U50LV10E acceleration card since a more hardware-friendly design could lead you to a better score.
7.	For more information regarding Vitis-AI such as supported frameworks, DPU operations and limitations, Quantizer usage, see the following link: https://www.xilinx.com/support/documentation/sw_manuals/vitis_ai/1_3/ug1414-vitis-ai.pdf
