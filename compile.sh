#!/bin/sh

#  Copyright 2021 Industrial Technology Research Institute
#
#  Copyright 2020 Xilinx Inc.
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#
#  NOTICE: This file has been modified by Industrial Technology Research Institute for AIdea "FPGA Edge AI – AOI Defect
#  Classification" competition tutorial
#
#  Original Author: Mark Harvey, Xilinx Inc.

if [ $1 = zcu102 ]; then
      ARCH=/opt/vitis_ai/compiler/arch/DPUCZDX8G/ZCU102/arch.json
      echo "-----------------------------------------"
      echo "COMPILING MODEL FOR ZCU102.."
      echo "-----------------------------------------"
elif [ $1 = u50 ]; then
      ARCH=/opt/vitis_ai/compiler/arch/DPUCAHX8H/U50/arch.json
      echo "-----------------------------------------"
      echo "COMPILING MODEL FOR ALVEO U50.."
      echo "-----------------------------------------"
elif [ $1 = u50lv ]; then
      ARCH=/opt/vitis_ai/compiler/arch/DPUCAHX8H/U50LV10E/arch.json
      echo "-----------------------------------------"
      echo "COMPILING MODEL FOR ALVEO U50lv.."
      echo "-----------------------------------------"
else
      echo  "Target not found. Valid choices are: zcu102, u50, u50lv ..exiting"
      exit 1
fi

compile() {
      vai_c_tensorflow2 \
            --model           quant_model/q_model.h5 \
            --arch            $ARCH \
            --output_dir      compiled_model \
            --net_name        deploy
}


compile 2>&1 | tee compile.log


echo "-----------------------------------------"
echo "MODEL COMPILED"
echo "-----------------------------------------"



