extends Node

@warning_ignore("unused_signal")
signal level_start(level_number:int)

@warning_ignore("unused_signal")
signal level_complete(level_number:int)

@warning_ignore("unused_signal")
signal game_over

@warning_ignore("unused_signal")
signal torched_a_ghost

@warning_ignore("unused_signal")
signal start_main_game

@warning_ignore("unused_signal")
signal return_to_main_menu

@warning_ignore("unused_signal")
signal retry_level

@warning_ignore("unused_signal")
signal wall_removed

@warning_ignore("unused_signal")
signal load_torches(torch_count:int)

@warning_ignore("unused_signal")
signal torch_thrown

@warning_ignore("unused_signal")
signal out_of_torches
