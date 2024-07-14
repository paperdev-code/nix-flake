#!/usr/bin/env nu
let plugins = open plugins.json

def latest-tag-from-github [repo: string] {
  let api_url = $'https://api.github.com/repos/($repo)/tags'
  let tag_name = http get $api_url | get 0 | $in.name
  let archive_url = $'https://github.com/($repo)/archive/refs/tags/($tag_name).tar.gz'
  $archive_url
}

def nix-prefetch-source [url: string] {
  let base32 = ^nix-prefetch-url --unpack --name source --type sha256 $url
  ^nix hash to-sri --type sha256 $base32
}

$plugins | transpose name meta | par-each { |plugin|
  let url = latest-tag-from-github $plugin.meta._github
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
