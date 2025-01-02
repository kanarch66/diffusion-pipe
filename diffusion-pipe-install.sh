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
bash Miniconda3-latest-Linux-x86_64.sh -b -p /home/user/miniconda3

source ~/.bashrc

# Clone the diffusion-pipe repository
git clone --recurse-submodules https://github.com/tdrussell/diffusion-pipe
cd diffusion-pipe

# Setup Miniconda environment
mkdir -p /home/user/miniconda3
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O home/user/miniconda3/miniconda.sh
bash /home/user/miniconda3/miniconda.sh -b -u -p /home/user/miniconda3
rm /home/user/miniconda3/miniconda.sh
source /home/user/miniconda3/bin/activate
conda init --all
conda create -n diffusion-pipe python=3.12
conda activate diffusion-pipe

# Install required Python packages
pip install torch==2.4.1 torchvision==0.19.1 --index-url https://download.pytorch.org/whl/cu121 --user
pip install torchaudio==2.4.1+cu121 --index-url https://download.pytorch.org/whl/cu121 --user

# Setup models
cd /home/user/diffusion-pipe/

# Install requirements
pip install -r requirements.txt

# Create necessary directories
mkdir -p models/{hunyuan,clip,llm}
# Download HunyuanVideo models into the hunyuan folder
wget -P models/hunyuan https://huggingface.co/Kijai/HunyuanVideo_comfy/resolve/main/hunyuan_video_720_cfgdistill_fp8_e4m3fn.safetensors
wget -P models/hunyuan https://huggingface.co/Kijai/HunyuanVideo_comfy/resolve/main/hunyuan_video_vae_bf16.safetensors
# Clone CLIP model into the clip folder
git clone --progress https://huggingface.co/openai/clip-vit-large-patch14 models/clip

# Clone LLaVA-LLama model into the llm folder
git clone --progress https://huggingface.co/Kijai/llava-llama-3-8b-text-encoder-tokenizer models/llm

# Prepare training data directory
mkdir -p /home/user/diffusion-pipe/training_data/images

#Symlink to ComfyUI
mkdir -p /workspace/ComfyUI/models/LLM/llava-llama-3-8b-text-encoder-tokenizer
cd /workspace/ComfyUI/models/LLM/llava-llama-3-8b-text-encoder-tokenizer
for file in /home/user/diffusion-pipe/models/llm/*; do
    ln -s "$file" "$(pwd)/$(basename "$file")"
done
mkdir -p /workspace/ComfyUI/models/clip/clip-vit-large-patch14
cd /workspace/ComfyUI/models/clip/clip-vit-large-patch14
for file in /home/user/diffusion-pipe/models/clip/*; do
    ln -s "$file" "$(pwd)/$(basename "$file")"
done
ln -s /home/user/diffusion-pipe/models/hunyuan/hunyuan_video_vae_bf16.safetensors /workspace/ComfyUI/models/vae
ln -s /home/user/diffusion-pipe/models/hunyuan/hunyuan_video_720_cfgdistill_fp8_e4m3fn.safetensors /workspace/ComfyUI/models/diffusion_models/Hunyuan

