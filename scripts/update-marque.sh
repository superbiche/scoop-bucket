#!/usr/bin/env bash
# Point bucket/marque.json at the latest superbiche/marque release, after
# checking that release's provenance: SHA256SUMS and the MSI must carry GitHub
# build provenance from marque's release workflow for that tag, and the MSI
# must match SHA256SUMS. Writes `version=<new version>` to $GITHUB_OUTPUT when
# the manifest changed. Needs gh with GH_TOKEN, and jq.
set -euo pipefail
repo=superbiche/marque
manifest=bucket/marque.json
fail() { echo "::error::$*" >&2; exit 1; }

tag="$(gh release view --repo "$repo" --json tagName --jq .tagName)"
[[ "$tag" =~ ^v([0-9]+\.[0-9]+\.[0-9]+)$ ]] || fail "latest marque release '$tag' is not a stable vX.Y.Z tag"
version="${BASH_REMATCH[1]}"
current="$(jq -r .version "$manifest")"
if [[ "$version" == "$current" ]]; then
  echo "marque manifest is at $current, the latest release"
  exit 0
fi

msi="Marque_${version}_x64_en-US.msi"
work="$(mktemp -d)"
gh release download "$tag" --repo "$repo" --pattern SHA256SUMS --pattern "$msi" --dir "$work"
for f in SHA256SUMS "$msi"; do
  gh attestation verify "$work/$f" --repo "$repo" \
    --signer-workflow "$repo/.github/workflows/release.yml" \
    --source-ref "refs/tags/$tag" >/dev/null \
    || fail "$f of $tag has no valid provenance from $repo's release workflow"
done
hash="$(awk -v f="$msi" '$2 == f { print $1 }' "$work/SHA256SUMS")"
[[ "$hash" =~ ^[0-9a-f]{64}$ ]] || fail "SHA256SUMS of $tag has no entry for $msi"
(cd "$work" && sha256sum --quiet --ignore-missing -c SHA256SUMS) || fail "$msi does not match SHA256SUMS"

url="https://github.com/$repo/releases/download/$tag/$msi"
jq --indent 4 --arg v "$version" --arg u "$url" --arg h "$hash" \
  '.version = $v | .architecture."64bit".url = $u | .architecture."64bit".hash = $h' \
  "$manifest" > "$work/marque.json"
mv "$work/marque.json" "$manifest"
echo "marque manifest: $current -> $version"
echo "version=$version" >> "${GITHUB_OUTPUT:-/dev/stdout}"
