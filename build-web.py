"""Prepare an online copy while preserving the local standalone handoff."""
from pathlib import Path
import base64
import hashlib
import json
import re
import shutil

ROOT = Path(__file__).resolve().parent
SOURCE = ROOT / "dist"
WEB = ROOT / "out"
WEB.mkdir(exist_ok=True)
(WEB / "previews").mkdir(exist_ok=True)
(WEB / "assets").mkdir(exist_ok=True)
html = (SOURCE / "index.html").read_text()
source_hash = hashlib.sha256(html.encode()).hexdigest()
previews = {}
lines = []
for line in html.splitlines(keepends=True):
    if line.strip().startswith("const standalonePreviews = "):
        previews.update(json.loads(line.strip()[len("const standalonePreviews = "):-1]))
    elif re.match(r'\s*standalonePreviews\["', line):
        match = re.fullmatch(r'\s*standalonePreviews\[("[^"]+")\] = (.*);\s*', line)
        assert match, "Unexpected preview assignment"
        previews[json.loads(match[1])] = json.loads(match[2])
    else:
        lines.append(line)
assert previews, "No animation previews found"
html = "".join(lines)
types = {"image/png": "png", "image/webp": "webp", "image/svg+xml": "svg",
         "video/mp4": "mp4", "video/webm": "webm", "video/quicktime": "mov", "audio/mpeg": "mp3"}
asset_count = 0

def externalize(content, asset_prefix):
    def extract(match):
        global asset_count
        mime, encoded = match.groups()
        raw = base64.b64decode(encoded, validate=True)
        name = hashlib.sha256(raw).hexdigest() + "." + types[mime]
        path = WEB / "assets" / name
        if not path.exists():
            path.write_bytes(raw)
            asset_count += 1
        return asset_prefix + name
    return re.sub(r'data:([^;,\s]+);base64,([A-Za-z0-9+/]+={0,2})', extract, content)

for identifier, preview in previews.items():
    (WEB / "previews" / (identifier + ".html")).write_text(externalize(preview, "../assets/"))

html = html.replace('new URL(current.path, window.location.href)',
                    'new URL("previews/" + encodeURIComponent(current.id) + ".html", window.location.href)')
start = html.index("      function getStandalonePreview() {")
end = html.index("      const navGroups = [", start)
html = html[:start] + '''      function loadPreview() {
        previewFrame.removeAttribute("srcdoc");
        previewFrame.src = getPreviewPath(true);
      }

      function updateOpenButton() {
        openButton.href = getPreviewPath();
      }

''' + html[end:]
assert "standalonePreviews" not in html and "getStandalonePreview" not in html
(WEB / "index.html").write_text(externalize(html, "assets/"))
shutil.copytree(SOURCE / "animations", WEB / "animations", dirs_exist_ok=True)
for f in (WEB / "animations").rglob("index.html"):
    f.write_text(externalize(f.read_text(), "../../assets/"))
files = [p for p in WEB.rglob("*") if p.is_file()]
assert all(p.stat().st_size < 25 * 1024 * 1024 for p in files), "Oversized asset"
assert source_hash == hashlib.sha256((SOURCE / "index.html").read_bytes()).hexdigest()
print(json.dumps({"previews": len(previews), "files": len(files), "newAssets": asset_count,
                  "totalBytes": sum(p.stat().st_size for p in files),
                  "indexBytes": (WEB / "index.html").stat().st_size,
                  "largestFileBytes": max(p.stat().st_size for p in files),
                  "localSourceSHA256": source_hash}, indent=2))
