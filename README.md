# hero-rotation-generator

Parses SimC APLs to generate HeroRotation class module.

## Refresh profiles

The launch scripts are designed to automatically parse all the `.simc` profiles present in the `/profiles` folder.

### Windows

Using the command prompt in the root folder of the project,

```bash
.\launch.bat
```

Using PowerShell,

```bash
.\launch.ps1
```

### Unix

Using the command prompt in the root folder of the project,

```bash
./launch.sh
```

## Usage

The `hrgenerator` package can be used as a script with the following command:

```bash
python -m hrgenerator
```

You can get help from the module used as a script with:

```bash
python -m hrgenerator --help
```

The module can also be used in python in the following fashion:

```python
# Create an empty APL object
apl = APL()
# Read a profile from a .simc file
apl.read_profile('my_profile.simc')
# Parse and export the profile as a lua file
apl.export_lua('my_profile.lua')
```

## Status

Currently in development, alpha stage.
