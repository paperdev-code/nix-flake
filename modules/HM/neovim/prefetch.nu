#!/usr/bin/env nu
let plugins = open plugins.json

def latest-tag-from-github [repo: string] {
  let api_url = $'https://api.github.com/repos/($repo)/tags'
  let tag_name = http get $api_url | get 0 | $in.name
  $'https://github.com/($repo)/archive/refs/tags/($tag_name).tar.gz'
}

def latest-commit-from-github [repo: string] {
  let api_url = $'https://api.github.com/repos/($repo)/commits'
  let sha = http get $api_url | get 0 | $in.sha
  $'https://github.com/($repo)/archive/($sha).tar.gz'
}

def nix-prefetch-source [url: string] {
  let base32 = ^nix-prefetch-url --unpack --name source --type sha256 $url
  ^nix hash convert --hash-algo sha256 --to sri $base32
}

$plugins | transpose name meta | par-each { |plugin|
  let cmd = $plugin.meta.'_github' | split row ':'
  let url = match ($cmd.1) {
    'latest' => (latest-commit-from-github $cmd.0)
    'tagged' => (latest-tag-from-github $cmd.0)
  }
  let hash = nix-prefetch-source $url
  { $"($plugin.name)": (
    $plugin.meta
    | update hash $hash
    | update url $url
  ) }
  | sort
}
| reduce {|ps, p| $ps | merge $p}
| sort
| save -f ($env.FILE_PWD | path join plugins.json)
