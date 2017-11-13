# ARParser

Parser to generate AethysRotation APLs from simc profiles

## Usage

The `arparser.py` file currently can be used as a script with the following
command:

```bash
python ./arparser.py
```

This will execute the following commands:

```python
# Create an empty APL object
apl = APL()
# Read a profile from a .simc file
apl.read_profile('test_profile.simc')
# Parse and export the profile as a lua file
apl.export_lua('test_profile.lua')
```

## Status

Currently in development, alpha stage.
