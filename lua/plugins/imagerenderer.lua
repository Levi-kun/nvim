return {
	"3rd/image.nvim",
	build = false,
	opts = {
		backend = "kitty", -- or "ueberzugpp", "wezterm"
		integrations = {
			markdown = {
				enabled = true,
				clear_in_insert_mode = false,
				download_remote_images = true,
				only_render_image_at_cursor = false,
			},
		},
		max_width = nil,
		max_height = nil,
		max_width_window_percentage = 50,
		max_height_window_percentage = 50,
		kitty_method = "normal",
	},
}
