model_path=$1
ctx_len=$2
grid_size=$3
n_embd=$4
n_layer=$5
eval_dir=$6
vision_tower_dir=$7
image_position=$8
# 使用dirname命令获取父目录的路径
parent_dir=$(dirname "${model_path}")
# 切换到脚本所在目录的上两级目录
cd "$(dirname "$(dirname "$0")")/.."
# get the name of the model without extension
model_name=$(basename "${model_path}")
model_name="${model_name%.*}"
# 打印当前工作目录
echo "Current working directory: $(pwd)"

# 使用basename命令获取父目录名称
exp_name=$(basename "${parent_dir}")
# add model name to exp name
exp_name="${exp_name}_${model_name}"
echo "exp name: $exp_name, model path: $model_path"
echo "ctx_len: $ctx_len, grid_size: $grid_size, n_embd: $n_embd, n_layer: $n_layer"
echo "eval dir: $eval_dir"
echo "vision_tower_dir: $vision_tower_dir", "image_position: $image_position"

python evaluate.py \
    --ctx_len $ctx_len --grid_size $grid_size --n_embd $n_embd --n_layer $n_layer \
    --vision_tower_dir $vision_tower_dir \
    --model_path $model_path \
    --image_folder $eval_dir/eval/mm-vet/images \
    --question_file $eval_dir/eval/mm-vet/llava-mm-vet.jsonl \
    --output_file $eval_dir/eval/mm-vet/outputs/$exp_name.jsonl \
    --image_position $image_position

mkdir -p $eval_dir/eval/mm-vet/results

python eval/convert_mmvet_for_eval.py \
    --src $eval_dir/eval/mm-vet/outputs/$exp_name.jsonl \
    --dst $eval_dir/eval/mm-vet/results/$exp_name.json