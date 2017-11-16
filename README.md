# ARParser

Parser to generate AethysRotation APLs from simc profiles

## Usage

The `arparser` package can be used as a script with the following command:

```bash
python -m arparser
```

You can get help from the module used as a script with:

```bash
python -m arparser --help
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
