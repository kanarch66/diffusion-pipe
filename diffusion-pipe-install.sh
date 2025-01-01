#!/bin/bash

# Update and upgrade packages
sudo apt update
sudo apt full-upgrade -y

# Install required packages
sudo apt-get install -y git-lfs wget python3-dev build-essential

# Check NVIDIA GPU status
nvidia-smi

# Download and install Miniconda
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh -b -p /workspace/miniconda3

source ~/.bashrc

# Clone the diffusion-pipe repository
git clone --recurse-submodules https://github.com/tdrussell/diffusion-pipe
cd diffusion-pipe

# Setup Miniconda environment
mkdir -p ~/miniconda3
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh
bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
rm ~/miniconda3/miniconda.sh
source ~/miniconda3/bin/activate
conda init --all
conda create -n diffusion-pipe python=3.12
conda activate diffusion-pipe

# Install required Python packages
pip install torch==2.4.1 torchvision==0.19.1 --index-url https://download.pytorch.org/whl/cu121 --user
pip install torchaudio==2.4.1+cu121 --index-url https://download.pytorch.org/whl/cu121 --user

# Setup models
cd ~/diffusion-pipe

# Install requirements
pip install -r requirements.txt

# Create necessary directories
mkdir -p models/{hunyuan,clip,llm}
# Download HunyuanVideo models into the hunyuan folder
wget -P models/hunyuan https://huggingface.co/Kijai/HunyuanVideo_comfy/resolve/main/hunyuan_video_720_cfgdistill_fp8_e4m3fn.safetensors
wget -P models/hunyuan https://huggingface.co/Kijai/HunyuanVideo_comfy/resolve/main/hunyuan_video_vae_bf16.safetensors

# Clone CLIP model into the clip folder
git clone https://huggingface.co/openai/clip-vit-large-patch14 models/clip

# Clone LLaVA-LLama model into the llm folder
git clone https://huggingface.co/Kijai/llava-llama-3-8b-text-encoder-tokenizer models/llm

# Prepare training data directory
mkdir -p ~/training_data/images
