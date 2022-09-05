gistage_time += keyboard_check(vk_space);

gistage_curr += keyboard_check_pressed(vk_right) - keyboard_check_pressed(vk_left);
gistage_curr = clamp(gistage_curr, 0, 7);