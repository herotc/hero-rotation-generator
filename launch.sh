#!/usr/bin/env bash

python -m hrgenerator -p $(ls profiles/PreRaids/*.simc)
python -m hrgenerator -p $(ls profiles/Tier22/*.simc)
python -m hrgenerator -p $(ls profiles/Tier23/*.simc)
python -m hrgenerator -p $(ls profiles/Tier25/*.simc)