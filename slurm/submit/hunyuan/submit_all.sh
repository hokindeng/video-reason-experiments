#!/bin/bash
#
# Submit all hunyuan-video-i2v inference jobs
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

cd "$PROJECT_ROOT"

echo "🚀 Submitting all hunyuan-video-i2v jobs..."
echo "   Total tasks: 50"
echo "   Model: hunyuan-video-i2v"
echo ""

# Array to store job IDs
declare -a JOB_IDS


# Submit G-1_object_trajectory_data-generator
echo "Submitting: G-1_object_trajectory_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_G1.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit G-2_reorder_objects_data-generator
echo "Submitting: G-2_reorder_objects_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_G2.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit G-3_stable_sort_data-generator
echo "Submitting: G-3_stable_sort_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_G3.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit G-4_identify_objects_data-generator
echo "Submitting: G-4_identify_objects_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_G4.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit G-5_multi_object_placement_data-generator
echo "Submitting: G-5_multi_object_placement_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_G5.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit G-6_resize_object-data-generator
echo "Submitting: G-6_resize_object-data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_G6.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit G-7_return_to_correct_bin_data-generator
echo "Submitting: G-7_return_to_correct_bin_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_G7.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit G-8_track_object_movement_data-generator
echo "Submitting: G-8_track_object_movement_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_G8.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit G-9_identify_objects_in_region_data-generator
echo "Submitting: G-9_identify_objects_in_region_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_G9.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit G-10_matching_object_data-generator
echo "Submitting: G-10_matching_object_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_G10.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit G-11_handle_object_reappearance_data-generator
echo "Submitting: G-11_handle_object_reappearance_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_G11.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit G-12_grid_obtaining_award_data-generator
echo "Submitting: G-12_grid_obtaining_award_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_G12.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit G-13_grid_number_sequence_data-generator
echo "Submitting: G-13_grid_number_sequence_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_G13.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit G-14_grid_color_sequence-data-generator
echo "Submitting: G-14_grid_color_sequence-data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_G14.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit G-15_grid_avoid_obstacles_data-generator
echo "Submitting: G-15_grid_avoid_obstacles_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_G15.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit G-16_grid_go_through_block_data-generator
echo "Submitting: G-16_grid_go_through_block_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_G16.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit G-17_grid_avoid_red_block_data-generator
echo "Submitting: G-17_grid_avoid_red_block_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_G17.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit G-18_grid_shortest_path_data-generator
echo "Submitting: G-18_grid_shortest_path_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_G18.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit G-19_sort_objects_by_rule_data-generator
echo "Submitting: G-19_sort_objects_by_rule_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_G19.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit G-20_precise_placement_data-generator
echo "Submitting: G-20_precise_placement_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_G20.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit G-21_multiple_occlusions_vertical_data-generator
echo "Submitting: G-21_multiple_occlusions_vertical_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_G21.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit G-22_attention_shift_same_data-generator
echo "Submitting: G-22_attention_shift_same_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_G22.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit G-23_combined_objects_no_spin_data-generator
echo "Submitting: G-23_combined_objects_no_spin_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_G23.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit G-24_separate_objects_no_spin_data-generator
echo "Submitting: G-24_separate_objects_no_spin_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_G24.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit G-25_seperate_object_spinning_data-generator
echo "Submitting: G-25_seperate_object_spinning_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_G25.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit G-26_maintain_object_identity_different_objects_data-generator
echo "Submitting: G-26_maintain_object_identity_different_objects_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_G26.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit G-27_read_the_chart_data_semantic_comprehension_data-generator
echo "Submitting: G-27_read_the_chart_data_semantic_comprehension_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_G27.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit G-28_read_the_chart_data_command_data-generator
echo "Submitting: G-28_read_the_chart_data_command_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_G28.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit G-29_chart_extreme_with_data_data-generator
echo "Submitting: G-29_chart_extreme_with_data_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_G29.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit G-30_chart_extreme_without_data_data-generator
echo "Submitting: G-30_chart_extreme_without_data_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_G30.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit G-31_directed_graph_navigation_data-generator
echo "Submitting: G-31_directed_graph_navigation_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_G31.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit G-32_undirected_graph_navigation_data-generator
echo "Submitting: G-32_undirected_graph_navigation_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_G32.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit G-33_visual_jenga_data-generator
echo "Submitting: G-33_visual_jenga_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_G33.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit G-34_object_packing_data-generator
echo "Submitting: G-34_object_packing_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_G34.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit G-35_hit_target_after_bounce_data-generator
echo "Submitting: G-35_hit_target_after_bounce_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_G35.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit G-36_multiple_occlusions_horizontal_data-generator
echo "Submitting: G-36_multiple_occlusions_horizontal_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_G36.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit G-37_symmetry_random_data-generator
echo "Submitting: G-37_symmetry_random_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_G37.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit G-38_symmetry_shape_data-generator
echo "Submitting: G-38_symmetry_shape_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_G38.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit G-39_attention_shift_different_data-generator
echo "Submitting: G-39_attention_shift_different_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_G39.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit G-40_combined_objects_spinning_data_generator
echo "Submitting: G-40_combined_objects_spinning_data_generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_G40.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit G-41_grid_highest_cost_data-generator
echo "Submitting: G-41_grid_highest_cost_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_G41.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit G-42_grid_lowest_cost_data-generator
echo "Submitting: G-42_grid_lowest_cost_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_G42.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit G-43_understand_scene_structure_data-generator
echo "Submitting: G-43_understand_scene_structure_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_G43.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit G-44_bfs_data-generator
echo "Submitting: G-44_bfs_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_G44.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit G-45_key_door_matching_data-generator
echo "Submitting: G-45_key_door_matching_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_G45.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit G-46_find_keys_and_open_doors_data-generator
echo "Submitting: G-46_find_keys_and_open_doors_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_G46.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit G-47_multiple_keys_for_one_door_data-generator
echo "Submitting: G-47_multiple_keys_for_one_door_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_G47.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit G-48_multiple_bounces_data-generator
echo "Submitting: G-48_multiple_bounces_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_G48.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit G-49_complete_missing_contour_segments_data-generator
echo "Submitting: G-49_complete_missing_contour_segments_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_G49.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit G-50_suppress_spurious_edges_data-generator
echo "Submitting: G-50_suppress_spurious_edges_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_G50.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

echo ""
echo "✅ All jobs submitted successfully!"
echo ""
echo "Submitted job IDs: ${JOB_IDS[@]}"
echo ""
echo "Monitor all jobs with:"
echo "   squeue -u $USER"
echo ""
echo "View summary:"
echo "   squeue -u $USER | grep hunyuan"
echo ""
echo "Cancel all jobs if needed:"
echo "   scancel ${JOB_IDS[@]}"
echo ""
echo "Or cancel all hunyuan jobs:"
echo "   scancel -u $USER -n hunyuan-G*"
