#!/bin/bash

# Update and upgrade packages
sudo apt update
sudo apt full-upgrade -y

# Install required packages
sudo apt-get install -y git-lfs wget python3-dev build-essential

# Check NVIDIA GPU status
nvidia-smi

# Download and install Miniconda
wget -q https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh

# Install Miniconda silently
bash ~/miniconda.sh -b -p ~/miniconda3

# Ensure Miniconda is added to PATH
echo 'export PATH="$HOME/miniconda3/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# Clean up the installation script
rm ~/miniconda.sh

# Verify installation
conda --version


# Clone the diffusion-pipe repository
git clone --recurse-submodules https://github.com/tdrussell/diffusion-pipe
cd diffusion-pipe

# Setup Miniconda environment
mkdir -p /home/user/miniconda3
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /home/user/miniconda3/miniconda.sh
bash /home/user/miniconda3/miniconda.sh -b -u -p /home/user/miniconda3
rm /home/user/miniconda3/miniconda.sh

# Initialize Conda for all shells
source /home/user/miniconda3/bin/activate
conda init --all

# Create the environment and activate it
conda create -n diffusion-pipe python=3.12
conda activate diffusion-pipe

# Check if Conda is activated
if [[ -n "$CONDA_DEFAULT_ENV" ]]; then
    echo -e "\033[38;5;196m🌈 Conda environment activated! 🌈\033[0m" # Red
    echo -e "\033[38;5;202m🌈 Conda environment activated! 🌈\033[0m" # Orange
    echo -e "\033[38;5;226m🌈 Conda environment activated! 🌈\033[0m" # Yellow
    echo -e "\033[38;5;46m🌈 Conda environment activated! 🌈\033[0m" # Green
    echo -e "\033[38;5;51m🌈 Conda environment activated! 🌈\033[0m" # Blue
    echo -e "\033[38;5;105m🌈 Conda environment activated! 🌈\033[0m" # Indigo
    echo -e "\033[38;5;171m🌈 Conda environment activated! 🌈\033[0m" # Violet
else
    echo "Conda is not activated."
fi

# Install required Python packages
pip install torch==2.4.1 torchvision==0.19.1 --index-url https://download.pytorch.org/whl/cu121 --user
pip install torchaudio==2.4.1+cu121 --index-url https://download.pytorch.org/whl/cu121 --user

# Setup models
cd home/user/diffusion-pipe

# Install requirements
pip install -r requirements.txt

# Create necessary directories
mkdir -p models/{hunyuan,clip,llm}
# Download HunyuanVideo models into the hunyuan folder
# Setup warning message in shades of orange for downloading gigantic files
echo -e "\033[38;5;214mWARNING: You are about to download large files! Please ensure your terminal stays open.\033[0m"
echo -e "\033[38;5;214mWARNING: This may take some time depending on your internet speed.\033[0m"
echo -e "\033[38;5;214mDo not close the terminal while downloading! Once finished, ComfyUI interface will popup\033[0m"

wget -P models/hunyuan https://huggingface.co/Kijai/HunyuanVideo_comfy/resolve/main/hunyuan_video_720_cfgdistill_fp8_e4m3fn.safetensors
wget -P models/hunyuan https://huggingface.co/Kijai/HunyuanVideo_comfy/resolve/main/hunyuan_video_vae_bf16.safetensors
# Clone CLIP model into the clip folder
GIT_TRACE=1 git clone --progress --verbose https://huggingface.co/openai/clip-vit-large-patch14 models/clip | pv

# Clone LLaVA-LLama model into the llm folder
GIT_TRACE=1 git clone --progress --verbose https://huggingface.co/Kijai/llava-llama-3-8b-text-encoder-tokenizer models/llm | pv

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
ln -s /home/user/diffusion-pipe/models/hunyuan/hunyuan_video_vae_bf16.safetensors /workspace/ComfyUI/models/vae/
mkdir -p /workspace/ComfyUI/models/diffusion_models/Hunyuan
ln -s /home/user/diffusion-pipe/models/hunyuan/hunyuan_video_720_cfgdistill_fp8_e4m3fn.safetensors /workspace/ComfyUI/models/diffusion_models/Hunyuan

#Download upscaler
wget -p https://huggingface.co/FacehugmanIII/4x_foolhardy_Remacri/resolve/main/4x_foolhardy_Remacri.pth /workspace/ComfyUI/models/upscale_models
#If conda is not created, follow this link https://docs.anaconda.com/miniconda/install/#quick-command-line-install

