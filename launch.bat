@echo off
for %%v in (profiles\PreRaids\*.simc) do python -m hrgenerator -p %%v
for %%v in (profiles\Tier22\*.simc) do python -m hrgenerator -p %%v
for %%v in (profiles\Tier23\*.simc) do python -m hrgenerator -p %%v
