# Refresh packages/antigravity-acp/release.json from the ACP Registry.
#
# The Nix expression reads this JSON rather than being rewritten. nix-update
# copies this file into the store and runs it from the flake root. Write
# $ANTIGRAVITY_ACP_RELEASE_FILE (or packages/antigravity-acp/release.json in
# $PWD), never a store path beside this script.
#
# Upstream registry: https://cdn.agentclientprotocol.com/registry/v1/latest/registry.json
# Agent id: antigravity-acp (Google Antigravity ACP server used by Zed).

const REGISTRY_URL = "https://cdn.agentclientprotocol.com/registry/v1/latest/registry.json"
const AGENT_ID = "antigravity-acp"

# ACP target names -> Nix systems. Windows archives are intentionally omitted.
# Rows are ordered so the generated JSON matches sorted keys.
const PLATFORMS = [
  [acp system];
  ["darwin-aarch64" "aarch64-darwin"]
  ["linux-aarch64" "aarch64-linux"]
  ["darwin-x86_64" "x86_64-darwin"]
  ["linux-x86_64" "x86_64-linux"]
]

def release-file []: nothing -> path {
  $env.ANTIGRAVITY_ACP_RELEASE_FILE?
  | default ($env.PWD | path join packages antigravity-acp release.json)
}

def fetch-agent [] {
  let registry = http get $REGISTRY_URL
  let agents = if ($registry | describe -d).type == "record" {
    $registry.agents? | default $registry
  } else {
    $registry
  }
  let matches = $agents | where id == $AGENT_ID
  if ($matches | is-empty) {
    error make {msg: $"antigravity-acp: agent ($AGENT_ID) missing from ACP registry"}
  }
  $matches | first
}

def prefetch-sri [url: string]: nothing -> string {
  let result = (^nix store prefetch-file --json $url | from json)
  $result.hash
}

def release-from-agent [agent]: nothing -> record {
  let binary = $agent.distribution.binary
  mut sources = {}
  for row in $PLATFORMS {
    let entry = $binary | get -i $row.acp
    if $entry == null {
      error make {msg: $"antigravity-acp: registry missing platform ($row.acp)"}
    }
    let url = $entry.archive
    print $"prefetching ($row.system): ($url)"
    $sources = $sources | insert $row.system {
      hash: (prefetch-sri $url)
      url: $url
    }
  }
  {
    sources: $sources
    version: $agent.version
  }
}

def main [] {
  let file = release-file
  if not ($file | path exists) {
    error make {msg: $"antigravity-acp: missing ($file). Run from the flake root."}
  }

  let release = release-from-agent (fetch-agent)
  ($release | to json --indent 2) + (char nl) | save --force $file
  print $"updated antigravity-acp to ($release.version)"
}
