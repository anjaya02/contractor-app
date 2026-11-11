"""Serve a local Flutter preview and forward the two allowed API calls.

Development only: this avoids browser CORS restrictions without changing SLT's
service or introducing an application backend. Binds to the local machine only.
"""
import argparse
import functools
import http.server
import pathlib
import urllib.error
import urllib.parse
import urllib.request

UPSTREAM = "https://serviceportal.slt.lk/ApiGisCon/public/api/"
ALLOWED_PATHS = {"/api/getUserData", "/api/getEquipmentView"}


class PreviewHandler(http.server.SimpleHTTPRequestHandler):
    def log_message(self, *_args):
        pass  # Do not log user details, request bodies or API keys.

    def do_POST(self):
        if self.path not in ALLOWED_PATHS:
            self.send_error(404)
            return
        try:
            length = int(self.headers.get("Content-Length", "0"))
        except ValueError:
            self.send_error(400)
            return
        if length < 1 or length > 8192:
            self.send_error(413)
            return
        request = urllib.request.Request(
            UPSTREAM + self.path.rsplit("/", 1)[1],
            data=self.rfile.read(length), method="POST",
            headers={"Content-Type": "application/json", "Accept": "application/json"},
        )
        try:
            response = urllib.request.urlopen(request, timeout=25)
        except urllib.error.HTTPError as error:
            response = error
        except (urllib.error.URLError, TimeoutError):
            self.send_error(502, "Service unavailable")
            return
        with response:
            body = response.read()
            self.send_response(response.status)
            self.send_header("Content-Type", response.headers.get("Content-Type", "application/json"))
            self.send_header("Content-Length", str(len(body)))
            self.send_header("Cache-Control", "no-store")
            self.end_headers()
            self.wfile.write(body)

    def do_GET(self):
        # Keys embedded in the web bundle stay on the local preview machine.
        path = urllib.parse.unquote(urllib.parse.urlsplit(self.path).path)
        if path.startswith("/api/"):
            self.send_error(405)
            return
        super().do_GET()


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--port", type=int, default=8080)
    args = parser.parse_args()
    root = pathlib.Path(__file__).resolve().parent.parent / "build" / "web"
    if not (root / "index.html").exists():
        parser.error("Build the Flutter web app first using tool/preview.ps1.")
    handler = functools.partial(PreviewHandler, directory=str(root))
    server = http.server.ThreadingHTTPServer(("127.0.0.1", args.port), handler)
    print(f"GIS Contractor preview: http://127.0.0.1:{args.port}", flush=True)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        server.server_close()
