# AIdea FPGA Edge AI – AOI Tutorial #

This tutorial shows you how to generate a baseline .xmodel for AIdea AOI contest on FPGA (Xilinx Alveo U50LV10E) using
codes modified from [Xilinx Vitis AI TensorFlow 2 Design Flow Tutorial](https://github.com/Xilinx/Vitis-AI-Tutorials/blob/master/Design_Tutorials/08-tf2_flow/README.md)
by AIdea members. We hope that by following these steps, you could become more familiar with Vitis-AI and the
competition.

## Step 0: Meet Prerequisite

Follow the instructions of `VitisAI_TF2-Tutorial.pdf` to build Vitis-AI CPU or GPU docker.

Download [VitisAI_TF2-Tutorial.pdf](http://buckets.aidea-web.tw/VitisAI_TF2_Tutorial.pdf)

## Step 1: Clone Repo

Enter Vitis-AI CPU or GPU docker container and then download this repository at the directory that you want. (e.g.
workspace)

```sh
$ git clone https://github.com/ITRI-AIdea/AIdea-FPGA-Edge-AI.git
```

## Step 2: Download Datasets

Enter `AIdea-FPGA-Edge-AI` directory. Use AIdea CLI tool to download training images and label file (`train_images.zip` 
and `train.csv`).

```sh
$ cd AIdea-FPGA-Edge-AI
```

AIdea CLI tool usage: https://github.com/ITRI-AIdea/aidea-cli

## Step 3: Unzip Datasets

Unzip the downloaded `train_images.zip`

```sh
$ unzip train_images.zip
```

## Step 4: Label Datasets

Execute `aoi_rename.py` to rename and label the training images.

```sh
$ python3 aoi_rename.py
```

## Step 5: Prepare Datasets

Create `dataset/train` directory to store training images. Copy the labeled training images to the `dataset/train`
directory.

```sh
$ mkdir dataset
$ cd dataset
$ mkdir train
$ cd ..
$ cp -r train_images/. dataset/train/
```

## Step 6: Activate Environment

Activate the Tensorflow2 Python virtual environment (you should see the prompt change to indicate that the environment
is active)

```	sh
$ conda activate vitis-ai-tensorflow2
```

## Step 7: Convert Images

The `images_to_tfrec.py` will do the following:

* Convert the images in PNG format into TFRecord format to speed up training.
* Split the images into train (80%) and test (20%) datasets. 
  
The TFRecord files(`*.tfrecord`) will be saved into `tfrecords` directory.

```sh
$ python -u images_to_tfrec.py 2>&1 | tee tfrec.log
```

## Step 8: Train Model

Training uses the following three files: `train.py`, `dataset_utils.py`, and `customcnn.py`. It will generate a 32-bits
floating-point model saved in .h5 format which could be used for quantization in the next step.

```sh
$ python -u train.py 2>&1 | tee train.log
```

## Step 9: Quantize Model

Xilinx FPGA cards execute models with parameters in integer format. Thus, we need to transfer our floating-point models
into fix-point models. This process is known as quantization and can be achieved by using Vitis-AI Quantizer.

```sh
$ python -u quantize.py --evaluate 2>&1 | tee quantize.log
```

## Step 10: Compile Model

Vitis-AI Compiler can compile .xmodel which contains instructions and data to be executed by FPGA cards. Note that we
need to specify which FPGA target board we want to run inference on. In this competition, we use Xilinx Alveo U50LV10E
acceleration card. The compiled .xmodel will be saved in the `compiled_model` directory.

```sh
$ source compile.sh u50lv
```

## Step 11: Upload .xmodel

When you go to the `compiled_model` directory, you should see `deploy.xmodel`. Zip `deploy.xmodel` (only English letters 
and numbers are allowed in naming, no special character) and then use AIdea CLI tool to hand in your work.

```sh
$ cd compiled_model/
$ zip -r model.zip deploy.xmodel
```

AIdea CLI tool usage: https://github.com/ITRI-AIdea/aidea-cli

## Server-side Inference Details

Your submission will be uploaded to an FPGA server to perform inference on a set of 10,000 test images (dimension: 512px
x 512px). Here are some details about the inference environment:

* Server
    * CPU: Intel® Core™ i7-10700 CPU @ 2.90GHz
    * RAM: 128 GB

* FPGA Card
    * Model: Xilinx® Alveo™ U50LV
    * DPU Configuration: DPUCAHX8H 10E275 (U50LV10E)
    * DPU Frequency: 275Mhz

* Inference Container
    * Docker image: `xilinx/vitis-ai-cpu:1.4.916`
    * Container memory usage limit: 96 GB
    * Inference script:
        ```sh
        # DPU IP selection
        source setup/alveo/setup.sh DPUCAHX8H;
        
        # Reset FPGA card before inference
        xbutil reset --device 0000:01:00.1;
      
        # Perform inference
        /opt/vitis_ai/conda/envs/vitis-ai-tensorflow2/bin/python3 app_mt_aidea.py --threads 4 --model deploy.xmodel; 
  
        # Reset FPGA card after inference
        xbutil reset --device 0000:01:00.1;
        ```
* Inference Code
    * [app_me_aidea.py](inference-code/app_mt_aidea.py)

## Important Notices

1. If you need help or have questions regarding this tutorial, feel free to ask
   here: https://aidea-web.tw/topic/701e1e79-84ff-49a5-86ee-a7f01c24c6f7#topic-discuss
2. This tutorial is tested using Vitis-AI 1.4 GPU docker with compatible Nvidia GPU and CUDA support. The provided codes
   are tested using Tensorflow2.3.
3. The network used in this tutorial is provided for you to get familiar with this competition. We encourage you to try
   designing your own network to score higher in the competition by optimizing for both 
   model accuracy and inference speed.
4. **When you try to modify codes, please make sure the following requirements are met, or your submission may fail:**
    * The size of input images: 512x512 pixels  
    * Input channels: 3  
    * .xmodel can run on Xilinx Alveo U50LV10E  
    * .xmodel is named as deploy.xmodel  
    * Submit .zip file with an arbitrary name (as long as it is composed of English letters or numbers)  
    * Submitted ZIP file contains only `deploy.xmodel`, without leading folder 

## Additional Tips

1. If you want to directly use PNG format images for training, you don’t need to use images_to_tfrec.py. Instead, you
   need to process images by yourself and make sure your model can accept PNG format input images.
2. If you want to change images usage during training or quantization, you can modify functions in dataset_utils.py.
3. If you want to design a more complex network architecture and you are ok with tensorflow2 framework, you can simply
   modify customcnn.py. Please noted that during scoring, both accuracy and throughput(FPS) will be considered. A more
   complex model will not guarantee a better score.
4. You can use other frameworks supported by Vitis-AI such as PyTorch or Caffe to develop your work. However, different
   frameworks have different quauntizers that take different input files.
5. Since U50LV10E acceleration card has multiple DPU cores, parallel programming and the reduction of dependencies are
   good approaches for better throughput.
6. It is highly encouraged to have a deeper understanding of FPGA cards or more specifically, Xilinx Alveo U50LV10E
   acceleration card since a more hardware-friendly design could lead you to a better score.
7. For more information regarding Vitis-AI such as supported frameworks, DPU operations and limitations, Quantizer
   usage, see the following link: https://www.xilinx.com/support/documentation/sw_manuals/vitis_ai/1_3/ug1414-vitis-ai.pdf
