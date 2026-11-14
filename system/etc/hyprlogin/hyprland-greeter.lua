-- Greeter compositor for hyprlogin (launched by greetd)

hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1,
})

hl.config({
    input = {
        kb_layout  = "us,fr",
        kb_variant = ",azerty",
        kb_options = "grp:alt_shift_toggle",
    },
})

hl.on("hyprland.start", function()
    hl.exec_cmd("hyprlogin --verbose; hyprctl dispatch 'hl.dsp.exit()'")
end)
