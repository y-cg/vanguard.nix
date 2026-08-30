# Refresh version and per-platform hashes in default.nix.
#
# Hashes come from `nix store prefetch-file` of the GitHub release assets,
# not from upstream .sha256 sidecars. nix-update's default path only rewrites
# the host system's src, so this script is wired as passthru.updateScript.
#
# nix-update copies this file into the store and runs it from the flake root.
# Patch $PLANNOTATOR_NIX_FILE (or packages/plannotator/default.nix in $PWD),
# never the store path of this script.

const REPO = "backnotprop/plannotator"
const ARCHES = ["darwin-arm64", "darwin-x64", "linux-arm64", "linux-x64"]

def nix-file []: nothing -> path {
  $env.PLANNOTATOR_NIX_FILE?
  | default ($env.PWD | path join packages plannotator default.nix)
}

def github-json [url: string] {
  let token = $env.GITHUB_TOKEN? | default ""
  if $token == "" {
    http get $url
  } else {
    http get --headers {Authorization: $"Bearer ($token)"} $url
  }
}

def latest-version []: nothing -> string {
  github-json $"https://api.github.com/repos/($REPO)/releases/latest"
  | get tag_name
  | str replace --regex '^v' ""
}

def prefetch-sri [url: string]: nothing -> string {
  ^nix store prefetch-file --json --hash-type sha256 $url
  | from json
  | get hash
}

# Replace the `hash = "..."` that immediately follows `arch = "<arch>";`.
def patch-hash [file: path, arch: string, new_hash: string] {
  mut pending = false
  mut out = []
  for line in (open $file | lines) {
    if $line =~ $'arch = "($arch)";' {
      $pending = true
    }
    if $pending and ($line =~ 'hash = "') {
      $pending = false
      $out = $out | append (
        $line | str replace --regex 'hash = "[^"]+"' $'hash = "($new_hash)"'
      )
    } else {
      $out = $out | append $line
    }
  }
  $out | str join (char nl) | $in + (char nl) | save --force $file
}

def patch-version [file: path, version: string] {
  open $file
  | str replace --regex 'version = "[^"]+"' $'version = "($version)"'
  | save --force $file
}

def main [version?: string] {
  let file = nix-file
  if not ($file | path exists) {
    error make {msg: $"plannotator: missing ($file). Run from the flake root."}
  }

  let version = if ($version | default "") == "" {
    latest-version
  } else {
    $version
  }

  patch-version $file $version

  for arch in $ARCHES {
    let url = $"https://github.com/($REPO)/releases/download/v($version)/plannotator-($arch)"
    print --stderr $"prefetching ($arch)..."
    let sri = prefetch-sri $url
    patch-hash $file $arch $sri
    print --stderr $"  ($arch): ($sri)"
  }

  print $"updated plannotator to ($version)"
}
