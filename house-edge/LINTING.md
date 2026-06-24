# Linting & code health

This project uses [gdtoolkit](https://github.com/Scony/godot-gdscript-toolkit)
(`gdparse`, `gdlint`, `gdformat`) to catch GDScript syntax errors and enforce a
consistent style.

## Setup (once)

```
pip install gdtoolkit
```

## Usage

```
lint.bat        # check syntax + report style problems
lint.bat fix    # auto-format every script in scripts/ and globals/
```

Configuration lives in `.gdlintrc` (line length raised to 120; trailing
whitespace and unused-argument checks left as warnings rather than hard errors).

## About the "Identifier 'RunConfig' not declared" error

`RunConfig` (and `Settings`, `Audio`, `EnemyPool`) are **autoload singletons**
registered in `project.godot` under `[autoload]`. They are not normal classes,
so this error almost never means the code is wrong.

It appears when the editor fails to (re)register the singletons — most often
after script files are edited outside the editor, or when one autoload script
has a parse error that aborts the whole autoload chain.

Fix order:
1. **Project → Reload Current Project** (or restart the editor). This alone
   clears the error in the large majority of cases.
2. If it persists, run `lint.bat` — a real syntax error in *any* autoload script
   (`globals/*.gd`) will stop every singleton from registering. Fix the reported
   file.
3. Verify the autoloads still exist in **Project → Project Settings → Globals →
   Autoload**. `EnemyPool` should point at `res://scripts/enemy_pool.gd`.

A full `gdparse` pass on the current codebase reports **no syntax errors**, so a
project reload is the expected fix.
