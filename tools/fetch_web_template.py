"""Fetch only the Web release template from the official Godot template bundle."""

import argparse
import io
from pathlib import Path
from urllib.request import Request, urlopen
from zipfile import ZipFile


class RemoteZip(io.RawIOBase):
    def __init__(self, url):
        response = urlopen(Request(url, headers={"Range": "bytes=0-0"}), timeout=60)
        with response:
            if response.status != 206:
                raise RuntimeError("The template download server must support HTTP ranges")
            self.url = response.geturl()
            self.length = int(response.headers["Content-Range"].split("/")[-1])
        self.position = 0

    def seekable(self):
        return True

    def tell(self):
        return self.position

    def seek(self, offset, whence=io.SEEK_SET):
        if whence == io.SEEK_CUR:
            offset += self.position
        elif whence == io.SEEK_END:
            offset += self.length
        if offset < 0:
            raise ValueError("Negative seek")
        self.position = offset
        return offset

    def read(self, size=-1):
        size = self.length - self.position if size < 0 else min(size, self.length - self.position)
        if size <= 0:
            return b""
        end = self.position + size - 1
        request = Request(self.url, headers={"Range": f"bytes={self.position}-{end}"})
        with urlopen(request, timeout=120) as response:
            if response.status != 206:
                raise RuntimeError("The template server ignored an HTTP range")
            data = response.read()
        if len(data) != size:
            raise RuntimeError("Incomplete template download")
        self.position += len(data)
        return data


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--version", default="4.7.2")
    parser.add_argument("--debug", action="store_true")
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    url = (
        "https://github.com/godotengine/godot-builds/releases/download/"
        f"{args.version}-stable/Godot_v{args.version}-stable_export_templates.tpz"
    )
    with RemoteZip(url) as remote, ZipFile(remote) as archive:
        variant = "debug" if args.debug else "release"
        template = archive.read(f"templates/web_nothreads_{variant}.zip")
    # Reading each ZIP member also validates its CRC before installation.
    with ZipFile(io.BytesIO(template)) as web:
        if web.testzip() is not None:
            raise RuntimeError("Corrupted Web export template")
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_bytes(template)
    print(f"Installed Web template: {args.output} ({len(template)} bytes)")


if __name__ == "__main__":
    main()
