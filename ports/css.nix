# `@define-color` lines for GTK CSS, one per role.
colorscheme:
builtins.concatStringsSep "" (
  map (n: "@define-color ${n} ${colorscheme.roles.${n}};\n") (builtins.attrNames colorscheme.roles)
)
