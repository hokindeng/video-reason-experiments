#!/bin/bash
#
# Submit all hunyuan-video-i2v inference jobs
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

cd "$PROJECT_ROOT"

echo "🚀 Submitting all hunyuan-video-i2v jobs..."
echo "   Total tasks: 100"
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

# Submit O-1_color_mixing_data-generator
echo "Submitting: O-1_color_mixing_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_O1.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit O-2_pigment_color_mixing_subtractive_data-generator
echo "Submitting: O-2_pigment_color_mixing_subtractive_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_O2.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit O-3_symbol_reordering_data-generator
echo "Submitting: O-3_symbol_reordering_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_O3.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit O-4_symbol_substitution_data-generator
echo "Submitting: O-4_symbol_substitution_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_O4.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit O-5_symbol_deletion_data-generator
echo "Submitting: O-5_symbol_deletion_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_O5.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit O-6_2d_geometric_transformation_data-generator
echo "Submitting: O-6_2d_geometric_transformation_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_O6.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit O-7_shape_color_change_data-generator
echo "Submitting: O-7_shape_color_change_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_O7.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit O-8_shape_rotation_data-generator
echo "Submitting: O-8_shape_rotation_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_O8.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit O-9_shape_scaling_data-generator
echo "Submitting: O-9_shape_scaling_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_O9.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit O-10_shape_outline_fill_data-generator
echo "Submitting: O-10_shape_outline_fill_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_O10.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit O-11_shape_color_then_move_data-generator
echo "Submitting: O-11_shape_color_then_move_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_O11.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit O-12_shape_color_then_scale_data-generator
echo "Submitting: O-12_shape_color_then_scale_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_O12.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit O-13_shape_outline_then_move_data-generator
echo "Submitting: O-13_shape_outline_then_move_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_O13.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit O-14_shape_scale_then_outline_data-generator
echo "Submitting: O-14_shape_scale_then_outline_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_O14.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit O-15_ball_bounces_given_time_data-generator
echo "Submitting: O-15_ball_bounces_given_time_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_O15.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit O-16_color_addition_data-generator
echo "Submitting: O-16_color_addition_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_O16.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit O-17_color_subtraction_data-generator
echo "Submitting: O-17_color_subtraction_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_O17.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit O-18_glass_refraction_data-generator
echo "Submitting: O-18_glass_refraction_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_O18.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit O-19_mirror_reflection_data-generator
echo "Submitting: O-19_mirror_reflection_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_O19.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit O-20_balance_missing_weight_data-generator
echo "Submitting: O-20_balance_missing_weight_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_O20.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit O-21_construction_blueprint_data-generator
echo "Submitting: O-21_construction_blueprint_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_O21.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit O-22_construction_stack_data-generator
echo "Submitting: O-22_construction_stack_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_O22.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit O-23_domino_chain_branch_path_prediction_data-generator
echo "Submitting: O-23_domino_chain_branch_path_prediction_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_O23.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit O-24_domino_chain_gap_analysis_data-generator
echo "Submitting: O-24_domino_chain_gap_analysis_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_O24.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit O-25_LEGO_construction_assembly_data-generator
echo "Submitting: O-25_LEGO_construction_assembly_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_O25.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit O-26_logic_gate_data-generator
echo "Submitting: O-26_logic_gate_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_O26.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit O-27_move_2_object_to_2_target_data-generator
echo "Submitting: O-27_move_2_object_to_2_target_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_O27.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit O-28_torque_balance_reasoning_data-generator
echo "Submitting: O-28_torque_balance_reasoning_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_O28.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit O-29_ballcolor_data-generator
echo "Submitting: O-29_ballcolor_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_O29.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit O-30_bookshelf_data-generator
echo "Submitting: O-30_bookshelf_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_O30.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit O-31_ball_eating_data-generator
echo "Submitting: O-31_ball_eating_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_O31.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit O-32_rolling_ball_data-generator
echo "Submitting: O-32_rolling_ball_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_O32.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit O-33_counting_object_data-generator
echo "Submitting: O-33_counting_object_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_O33.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit O-34_dot_to_dot_task_data-generator
echo "Submitting: O-34_dot_to_dot_task_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_O34.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit O-35_edit_distance_data-generator
echo "Submitting: O-35_edit_distance_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_O35.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit O-36_grid_shift_data-generator
echo "Submitting: O-36_grid_shift_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_O36.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit O-37_light_sequence_data-generator
echo "Submitting: O-37_light_sequence_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_O37.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit O-38_majority_color_data-generator
echo "Submitting: O-38_majority_color_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_O38.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit O-39_maze_data-generator
echo "Submitting: O-39_maze_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_O39.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit O-40_mirror_clock_task_data-generator
echo "Submitting: O-40_mirror_clock_task_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_O40.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit O-41_nonogram_data-generator
echo "Submitting: O-41_nonogram_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_O41.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit O-42_object_permanence_data-generator
echo "Submitting: O-42_object_permanence_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_O42.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit O-43_object_subtraction_data-generator
echo "Submitting: O-43_object_subtraction_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_O43.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit O-44_rotation_puzzle_data-generator
echo "Submitting: O-44_rotation_puzzle_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_O44.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit O-45_sequence_completion_data-generator
echo "Submitting: O-45_sequence_completion_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_O45.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit O-46_shape_sorter_data-generator
echo "Submitting: O-46_shape_sorter_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_O46.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit O-47_sliding_puzzle_data-generator
echo "Submitting: O-47_sliding_puzzle_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_O47.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit O-48_sudoku_data-generator
echo "Submitting: O-48_sudoku_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_O48.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit O-49_symmetry_completion_data-generator
echo "Submitting: O-49_symmetry_completion_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_O49.slurm")
JOB_IDS+=($JOB_ID)
echo "  Job ID: $JOB_ID"

# Submit O-50_tetris_data-generator
echo "Submitting: O-50_tetris_data-generator"
JOB_ID=$(sbatch --parsable "$PROJECT_ROOT/slurm/hunyuan-video-i2v/jobs/generated/hunyuan_O50.slurm")
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
