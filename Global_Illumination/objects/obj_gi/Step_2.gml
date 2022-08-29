gistage_time = current_time;

gistage_dnse += mouse_wheel_down() - mouse_wheel_up();
gistage_dnse = clamp(gistage_dnse, 0, 25);

gistage_curr += keyboard_check_pressed(vk_right) - keyboard_check_pressed(vk_left);
gistage_curr = clamp(gistage_curr, 0, 6);