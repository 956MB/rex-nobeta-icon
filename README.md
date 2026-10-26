# rex-nobeta-icon

A small macOS command-line tool. It replaces the icon of the **Rex Beta** terminal app with the same gradient icon, but without the "BETA" pill.

The tool does not change the files inside the app. It sets a custom Finder icon on the app folder, the same as when you paste an icon in Get Info. The app's code signature stays valid.

## How it works

1. It loads the `AppIconLightPreview` image from the asset catalog of the installed app, or `AppIconDarkPreview` with `dark`. This is the normal Rex icon without the BETA pill.
2. It draws the image on a 1024 × 1024 canvas that follows the macOS icon grid.
3. It sets the result as the custom icon of the app with `NSWorkspace.setIcon(_:forFile:)`.
4. It restarts the Dock so that the Dock shows the new icon.

The tool does not include an icon image. It reads the image from your installed copy of Rex each time you run it.

## Requirements

- macOS on Apple Silicon or Intel
- Xcode or the Command Line Tools (`xcode-select --install`), to build the tool
- Rex Beta installed, by default at `/Applications/Rex Beta.app`

## Build and install

```sh
make              # builds ./rex-nobeta-icon
make install      # copies it to /usr/local/bin (use PREFIX=~/.local to change)
```

## Usage

```sh
rex-nobeta-icon                       # set the icon without the BETA pill
rex-nobeta-icon dark                  # same, with the dark artwork
rex-nobeta-icon --undo                # remove the custom icon
rex-nobeta-icon --app "/path/to/Rex Beta.app"
```

## Notes

- **Updates:** a Rex update replaces the app, and the BETA icon then comes back. Run the tool again after each update.
- **Running app:** if the Dock still shows the BETA icon while Rex runs, quit Rex and open it again.
- **Permission error:** if the tool says it could not set the icon, give your terminal App Management access in System Settings > Privacy & Security.
- **Image quality:** the source image is 256 px, so the icon can look a little soft when the Dock magnifies it.

## License

Public domain ([The Unlicense](LICENSE)).

This project is not related to the makers of Rex. All Rex artwork belongs to its owners.
