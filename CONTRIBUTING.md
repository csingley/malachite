# Contributing

## Checks

```sh
nix flake check
```

Every Base16 scheme in nixpkgs, each flavor and a Mocha test fixture go through `mkColorscheme`.
The check fails if a role is missing, a color is not `#rrggbb`, the slots in use do not survive the
round trip, a colorscheme does not serialize to JSON, or a source file reads a role that does not
exist. Contrast problems are warnings. It also builds every package and a real home-manager
configuration that enables the module and checks the generated files.

## Layout

```
flake.nix        flake-parts: inputs, outputs, wiring
default.nix      non-flake entry
lib/             color math, Base16, mkColorscheme
colorschemes/    emerald.nix, jade.nix
ports/<app>/     one per app
packages/        the core package and one package per port
modules/         the home-manager module
checks/          conformance checks; fixtures/ has the Mocha fixture
```

## Roles

Apps read roles, never slots. Every role is always present. Underscores keep a name valid in Nix,
Lua and CSS.

### Neutrals

| Role | Meaning |
|---|---|
| bg | background; text drawn on a colored fill |
| surface | raised areas: pills, a focused title bar |
| surface_subtle | a faint step above bg |
| selection | selection, hover and focus fill |
| border | borders and dividers |
| fg_faint | decoration: disabled items, scrollbars; never needed text |
| fg_subtle | tertiary text: punctuation, inactive items |
| fg_muted | secondary text |
| fg | primary text |
| cursor | the cursor |

Brightness order: `bg` < `surface_subtle` < `surface` < `selection` < `border` < `fg_faint` <
`fg_subtle` < `fg_muted` < `fg`.

### Signals

| Role | Meaning |
|---|---|
| error | something is wrong: errors, urgent, critical |
| warning | a state away from rest, worth a look: a warning, a low battery, a live microphone |
| success | healthy, done |
| info | neutral information |
| hint | lowest-severity suggestion |

A signal color is used for nothing else. How loudly `warning` is shown is the port's style: as text
it informs, as a fill or a flash it asks for action.

### Identity and syntax

| Role | Meaning |
|---|---|
| accent | focus and identity: the prompt, the focused element |
| keyword, string, func, type, number | the main syntax tones (`func`: `function` is a Lua keyword) |
| special | escapes, regex, a distinct extra hue |
| builtin, property, parameter, tag, operator, comment | secondary syntax tones |

`ansi` is the 16 terminal colors in ANSI order: black is `surface`, red `error`, green `success`,
yellow `warning`, blue `accent`, magenta `keyword`, cyan `special`, white `fg_muted`; the bright
colors are each 30% toward `fg`.

### Legibility

`fg_muted`, `fg_subtle` and `comment` are lightened until they reach 4.5:1 contrast on `bg`
(`legibility.minContrast`; 0 turns it off). Roles a colorscheme sets explicitly are never adjusted.
The checks warn when `fg` is under 4.5:1 or a signal or syntax color is under 3:1.

## Adding a port

A port turns a colorscheme into the files one app reads. `ports/<app>/default.nix` is a function
`{ lib, colorscheme, color, ... } -> { file, text, install, native? }`, listed in `ports/default.nix`:

- `file`: the artifact's name; `text`: its contents
- `install`: the `INSTALL.md` (where the file goes, the include line, how to reload)
- `native`: an extra path under `share/` where the app looks for themes by name (foot, btop)

Extra arguments (foot's `alpha`) are app style: named, with a default.

1. Read only `colorscheme.roles` and `colorscheme.ansi`; never slots, hex literals or a flavor name.
2. Never assume a hue or light versus dark.
3. App style (bold text, window translucency, which widget flashes) is a named option with a default.
4. Document next to the code which role each color uses.
5. Derive tints from roles with `color` (`lib/color.nix`; `malachite.lib.mix` and `ramp` are the same helpers for consumers).

A port holds the colors and the role-to-element mapping for the app's stock elements. A bespoke
design (custom widgets, shapes, animations) belongs to the consumer, which imports the port.

`packages/` installs each port for every flavor under `share/malachite/<flavor>/<port>/`, and
`nix flake check` builds them all.

## Packaging

Everything is architecture-independent data. Targets: the flake, a nixpkgs `package.nix`, an Arch
`PKGBUILD` and a `.deb` built with nfpm. A package never edits `$HOME`.

## Releasing

1. Set the version in `VERSION` and in `packaging/arch/PKGBUILD` (`pkgver`; a check compares them).
2. `nix build .#release` and put its sha256 in the PKGBUILD's `sha256sums`.
3. Commit, tag `v<version>`, push the tag: CI builds the tarball and the .deb and publishes both to
   the project's package registry.
