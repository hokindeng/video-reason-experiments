#!/bin/bash
# parallel run all questions directories in parallel, using 8 GPUs
# each task is assigned one GPU, and the load is balanced automatically

set -euo pipefail

# configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR"
QUESTIONS_DIR="$PROJECT_ROOT/data/questions"
OUTPUT_DIR="$PROJECT_ROOT/data/outputs"
MODEL="${1:-dynamicrafter-512}"  # default model
NUM_GPUS=8
LOG_DIR="$PROJECT_ROOT/logs/$MODEL"

# create log directory
mkdir -p "$LOG_DIR"

echo "============================================================"
echo "🚀 parallel inference script - using $NUM_GPUS GPUs"
echo "============================================================"
echo "model: $MODEL"
echo "questions directory: $QUESTIONS_DIR"
echo "output directory: $OUTPUT_DIR"
echo "log directory: $LOG_DIR"
echo ""

# collect all questions directories
echo "🔍 scan questions directories..."
question_dirs=()
while IFS= read -r -d '' dir; do
    # check if it contains _task directory
    if find "$dir" -maxdepth 1 -type d -name "*_task" | grep -q .; then
        question_dirs+=("$dir")
    fi
done < <(find "$QUESTIONS_DIR" -mindepth 1 -maxdepth 1 -type d -print0 | sort -z)

total_dirs=${#question_dirs[@]}
echo "✅ found $total_dirs questions directories"
echo ""

if [ $total_dirs -eq 0 ]; then
    echo "❌ no questions directories found!"
    exit 1
fi

# show the first few directories
echo "the first 5 directories:"
for i in $(seq 0 $((total_dirs < 5 ? total_dirs - 1 : 4))); do
    echo "  $((i+1)). $(basename "${question_dirs[$i]}")"
done
echo ""

# create task queue file
queue_file=$(mktemp)
trap "rm -f $queue_file" EXIT

# write all tasks to the queue
for dir in "${question_dirs[@]}"; do
    echo "$dir" >> "$queue_file"
done

# task counter
task_counter=0
completed_tasks=0
failed_tasks=0

# start background task function
run_task() {
    local gpu_id=$1
    local task_num=$2
    local question_dir=$3
    
    local dir_name=$(basename "$question_dir")
    local log_file="$LOG_DIR/gpu${gpu_id}_${dir_name}.log"
    
    echo "[GPU $gpu_id] 开始任务 $task_num: $dir_name" | tee -a "$LOG_DIR/master.log"
    
    # run inference
    cd "$PROJECT_ROOT"
    bash scripts/run_inference.sh \
        --model "$MODEL" \
        --gpu "$gpu_id" \
        --questions-dir "$question_dir" \
        
        > "$log_file" 2>&1
    
    local exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        echo "[GPU $gpu_id] ✅ task $task_num completed: $dir_name" | tee -a "$LOG_DIR/master.log"
        return 0
    else
        echo "[GPU $gpu_id] ❌ task $task_num failed: $dir_name (exit code: $exit_code)" | tee -a "$LOG_DIR/master.log"
        return 1
    fi
}

# main loop: assign tasks to GPUs from the queue
echo "🚀 start parallel execution..."
echo ""

# initialize GPU status array
declare -a gpu_pids
declare -a gpu_tasks
for i in $(seq 0 $((NUM_GPUS - 1))); do
    gpu_pids[$i]=""
    gpu_tasks[$i]=""
done

# read the queue and assign tasks
exec 3< "$queue_file"
while IFS= read -r question_dir <&3 || [ -n "$question_dir" ]; do
    if [ -z "$question_dir" ]; then
        continue
    fi
    
    # find idle GPU
    assigned=false
    while [ "$assigned" = false ]; do
        for gpu_id in $(seq 0 $((NUM_GPUS - 1))); do
            # check if the GPU is idle
            if [ -z "${gpu_pids[$gpu_id]}" ] || ! kill -0 "${gpu_pids[$gpu_id]}" 2>/dev/null; then
                # GPU is idle, assign task
                task_counter=$((task_counter + 1))
                
                # start background task
                (
                    run_task "$gpu_id" "$task_counter" "$question_dir"
                ) &
                
                gpu_pids[$gpu_id]=$!
                gpu_tasks[$gpu_id]="$question_dir"
                assigned=true
                
                echo "[scheduling] task $task_counter ($(basename "$question_dir")) → GPU $gpu_id (PID: ${gpu_pids[$gpu_id]})"
                break
            fi
        done
        
        # if no idle GPU, wait for a short time
        if [ "$assigned" = false ]; then
            sleep 2
        fi
    done
done
exec 3<&-

# wait for all tasks to complete
echo ""
echo "⏳ wait for all tasks to complete..."
echo ""

all_done=false
while [ "$all_done" = false ]; do
    all_done=true
    for gpu_id in $(seq 0 $((NUM_GPUS - 1))); do
        if [ -n "${gpu_pids[$gpu_id]}" ] && kill -0 "${gpu_pids[$gpu_id]}" 2>/dev/null; then
            all_done=false
        else
            # task completed, check exit status
            if [ -n "${gpu_pids[$gpu_id]}" ]; then
                wait "${gpu_pids[$gpu_id]}" 2>/dev/null
                exit_code=$?
                if [ $exit_code -eq 0 ]; then
                    completed_tasks=$((completed_tasks + 1))
                else
                    failed_tasks=$((failed_tasks + 1))
                fi
                gpu_pids[$gpu_id]=""
                gpu_tasks[$gpu_id]=""
            fi
        fi
    done
    
    if [ "$all_done" = false ]; then
        # show progress
        running=0
        for gpu_id in $(seq 0 $((NUM_GPUS - 1))); do
            if [ -n "${gpu_pids[$gpu_id]}" ] && kill -0 "${gpu_pids[$gpu_id]}" 2>/dev/null; then
                running=$((running + 1))
            fi
        done
        echo -ne "\r[progress] running: $running/$NUM_GPUS | completed: $completed_tasks | failed: $failed_tasks | total: $task_counter"
        sleep 5
    fi
done

echo ""
echo ""
echo "============================================================"
echo "✅ all tasks completed!"
echo "============================================================"
echo "total tasks: $task_counter"
echo "completed: $completed_tasks"
echo "failed: $failed_tasks"
echo ""
echo "📁 log file location: $LOG_DIR"
echo "   - master.log: master log"
echo "   - gpu*_*.log: task logs for each GPU"
echo ""
echo "📊 check failed tasks:"
grep -l "❌" "$LOG_DIR"/gpu*_*.log 2>/dev/null | head -5 || echo "no failed tasks"
echo ""

