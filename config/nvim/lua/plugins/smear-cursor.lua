return {
    'sphamba/smear-cursor.nvim',
    opts = {
        legacy_computing_symbols_support = true,
        legacy_computing_symbols_support_vertical_bars = true,

        hide_target_hack = true,
        never_draw_over_target = true,

        cursor_color = '#ff4000',

        stiffness = 0.6,
        trailing_stiffness = 0.35,
        matrix_pixel_threshold = 0.2,

        particles_enabled = true,
        particle_spread = 1,

        particles_per_second = 100,
        particles_per_length = 50,

        particle_max_num = 150,
        particle_max_lifetime = 800,
        particle_max_initial_velocity = 20,

        particle_velocity_from_cursor = 0.1,
        particle_random_velocity = 500,
        particle_damping = 0.15,
        particle_gravity = -80,
        min_distance_emit_particles = 0,

        filetypes_disabled = { 'neo-tree' }
    }
}
