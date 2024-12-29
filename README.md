https://civitai.com/articles/9798?highlight=728367&commentParentType=comment&commentParentId=727366&threadId=2096544#comments

## Training
Launch training with this command:

NCCL_P2P_DISABLE="1" NCCL_IB_DISABLE="1" deepspeed --num_gpus=1 train.py --deepspeed --config config.toml
## Monitoring Training
- Monitoring GPU usage in a windows terminal:

nvidia-smi --query-gpu=timestamp,name,temperature.gpu,utilization.gpu,memory.used,memory.total --format=csv -l 5
- Training outputs will be saved in the directory specified by output_dir in your config

## Resuming from checkpoint
If your computer crashes/you have to turn it off. use the --resume_from_checkpoint flag. If your gpu is a bit slow, consider checkpointing more regularly (uses a lot of storage space). eg:

NCCL_P2P_DISABLE="1" NCCL_IB_DISABLE="1" deepspeed --num_gpus=1 train.py --deepspeed --config config.toml --resume_from_checkpoint
## Using the Trained LoRA
### After training completes, find your LoRA file:
- Navigate to training output directory in Windows:

\\wsl$\Ubuntu\home\yourusername\training_output
- Look for the latest epoch folder

- Find the adapter.safetensors file
### Using with ComfyUI:
- Copy and rename the adapter.safetensors (to something descriptive) to your ComfyUI loras folder

- Make sure you have the HunyuanVideoWrapper node installed https://github.com/kijai/ComfyUI-HunyuanVideoWrapper

- Use the "HunyuanVideo Lora Select" node to load it

- Experiment with different epochs to find the ideal number for your dataset
## Preparing Training Data
1. Create dataset directory:
mkdir -p ~/training_data/images
2. Place training images in the directory:
- LoRA: 20-50 diverse images

- Optional: Create matching .txt files with prompts (same name as image file)


Example structure:

~/training_data/images
├── image1.png
├── image1.txt  # Optional prompt file
├── image2.png
├── image2.txt

