# sherpa-ws-prebuilts

Reproducible prebuild-Binaries des **sherpa-onnx WebSocket-Servers** für
[Audicap](https://github.com/audicap/audicap).

## Was ist hier drin?

Dieses Repo enthält einen GitHub-Actions-Workflow, der:

1. Den offiziellen sherpa-onnx-Release-Tarball (`osx-universal2-shared.tar.bz2`
   bzw. `win-x64-shared.tar.bz2`) von [k2-fsa/sherpa-onnx](https://github.com/k2-fsa/sherpa-onnx)
   herunterlädt.
2. Die Binary `sherpa-onnx-offline-websocket-server[.exe]` sowie die dafür
   benötigten dynamischen Bibliotheken (`.dylib` / `.dll`) extrahiert.
3. Als neues `.tar.gz` pro Plattform verpackt und als Release-Asset
   veröffentlicht — zusammen mit SHA256-Sidecar-Dateien.

## Versionspinning

| Release | Upstream sherpa-onnx | Build-Datum |
|---|---|---|
| `sherpa-v1.12.39-build1` | `v1.12.39` | (ergänzen nach erstem Release) |

## Verwendung

Audicap's Download-Script zieht automatisch aus dem passenden Release. Manueller
Download für Debugging:

```bash
curl -fL -O \
  https://github.com/audicap/sherpa-ws-prebuilts/releases/download/sherpa-v1.12.39-build1/sherpa-ws-macos.tar.gz
tar -xzf sherpa-ws-macos.tar.gz
./sherpa-onnx-offline-websocket-server --help
```

## Build-Trigger

- **Manuell:** Actions → "Build sherpa-ws-prebuilts" → Run workflow.
- **Automatisch:** Tag-Push mit Schema `sherpa-v<version>-build<N>` löst
  Release-Job aus.

## Sicherheit

- Alle Assets werden aus dem **offiziellen sherpa-onnx-Release-Tarball**
  extrahiert (verifizierbar via GH-Actions-Logs + Commit-SHA des Workflows).
- SHA256SUMS werden pro Release veröffentlicht.
- Audicap pinnt die Hashes im Client-Code; Mismatch → Abbruch.

## Lizenz

Apache-2.0 (wie sherpa-onnx upstream). Siehe `NOTICE` für Attribution.
