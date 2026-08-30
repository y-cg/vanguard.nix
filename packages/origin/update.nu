# Refresh packages/origin/release.json from Cursor's channel manifest.
#
# The Nix expression reads this JSON rather than being rewritten. nix-update
# copies this file into the store and runs it from the flake root. Write
# $ORIGIN_RELEASE_FILE (or packages/origin/release.json in $PWD), never a
# store path beside this script.
#
# `unstable` is accepted only as a spelling for the `latest` channel.

const CHANNELS = {
  stable: "stable"
  latest: "latest"
  unstable: "latest"
}

# Origin publishes more platforms than this derivation supports. Keeping this
# mapping explicit makes a newly supported platform an intentional packaging
# decision. Rows are ordered so the generated JSON matches sorted keys.
const PLATFORMS = [
  [platform system];
  ["darwin-arm64" "aarch64-darwin"]
  ["linux-arm64" "aarch64-linux"]
  ["darwin-x64" "x86_64-darwin"]
  ["linux-x64" "x86_64-linux"]
]

def release-file []: nothing -> path {
  $env.ORIGIN_RELEASE_FILE?
  | default ($env.PWD | path join packages origin release.json)
}

def sri-sha256 [digest: string]: nothing -> string {
  $"sha256-($digest | decode hex | encode base64)"
}

def fetch-manifest [channel: string] {
  http get $"https://downloads.cursor.com/co/channels/($channel)/manifest.json"
}

def release-from-manifest [manifest]: nothing -> record {
  mut sources = {}
  for row in $PLATFORMS {
    let asset = $manifest.platforms | get $row.platform
    $sources = $sources | insert $row.system {
      hash: (sri-sha256 $asset.sha256)
      url: $asset.url
    }
  }
  {
    sources: $sources
    version: $manifest.version
  }
}

def main [channel_name?: string] {
  let file = release-file
  if not ($file | path exists) {
    error make {msg: $"origin: missing ($file). Run from the flake root."}
  }

  let channel_name = $channel_name | default "stable"
  if $channel_name not-in ($CHANNELS | columns) {
    error make {msg: $"origin: unknown channel ($channel_name). Expected stable, latest, or unstable."}
  }
  let channel = $CHANNELS | get $channel_name

  let release = release-from-manifest (fetch-manifest $channel)
  ($release | to json --indent 2) + (char nl) | save --force $file
  print $"updated origin to ($release.version) \(($channel)\)"
}
