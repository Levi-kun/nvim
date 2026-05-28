return {
	"sphamba/smear-cursor.nvim",
	event = "VeryLazy", -- Loads cleanly after startup to keep things blazing fast
	opts = {
		cursor_color = "#FFFFFF",
		smear_between_buffers = true,
		scroll_buffer_space = true,
		smear_between_neighbor_lines = true,
		stiffness = 0.30,
		trailing_stiffness = 0.15,
		matrix_pixel_threshold = 0.85,
	},
}
