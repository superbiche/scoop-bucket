# superbiche/scoop-bucket

[Scoop](https://scoop.sh) manifests for projects maintained by [@superbiche](https://github.com/superbiche).

## marque

[Marque](https://github.com/superbiche/marque) is a desktop markdown viewer with folder workspaces.

```powershell
scoop bucket add superbiche https://github.com/superbiche/scoop-bucket
scoop install superbiche/marque
```

The manifest unpacks marque's MSI into Scoop's app directory, puts `marque` on `PATH` (`marque FILE` or `marque FOLDER`) and adds a Start menu shortcut. Marque needs the Microsoft Edge WebView2 runtime, which current Windows 10 and 11 include. The executable is not code-signed yet.

## How the manifest is updated

A daily workflow ([`update.yml`](.github/workflows/update.yml)) reads the latest marque release and changes the manifest only when:

- the release's `SHA256SUMS` and the `.msi` both carry GitHub build provenance from marque's release workflow for that tag (`gh attestation verify --signer-workflow superbiche/marque/.github/workflows/release.yml --source-ref refs/tags/<tag>`);
- the `.msi` matches `SHA256SUMS`;
- the updated manifest installs with Scoop on a Windows runner and provides `marque.exe` and its shim.

GitHub pauses scheduled workflows after 60 days without repository activity; running the workflow by hand resumes it.
