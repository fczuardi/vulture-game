# Vulture Glide: Carrion to Carry On

Another Open Source game by Fabricio C Zuardi


## License

MIT License
Copyright (c) 2025 Fabricio C Zuardi

## Credits and Aknowledges

This game was born as an entry for the 5-day-challenge "[Jamsepticeye](https://itch.io/jam/jamsepticeye)"
 with the theme _"Death is an Opportunity"_ in October 2025.

### Tools

- Godot (powerful, free-as-in-freedom, game engine and IDE)
- Neovim (I use Neovim, btw)
- Blender (used for creating the Terrain mesh, with the Landscape Plugin and Decimate Modifier)
- OpenAI (some help with the code)


## Contributing

### Getting external dependencies

Parts of this Godot project are not included in this repo, to the best of my ability I will try to
list the steps to reproduce the dev environment here.

#### Addons / tools

- [touch_screen_joystick](https://github.com/kent-2004/touch-screen-joystick)
    - by Kent Coyova, license MIT
- [GDQuest_GDScript_formatter](https://github.com/GDQuest/GDScript-formatter) (optional)
    - by GDQuest, license MIT
    - remember to `--use-spaces`

### Use your own keystore (Android Export)

The `.godot` folder is also excluded because it contains sensitive data such as credentials for apk
signing. Consult the latest documentation on [Exporting to Android](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html) if you want to be able to generate Android builds.
