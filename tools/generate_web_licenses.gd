extends SceneTree

# Run with the same official Godot build used to export the Web game. The engine
# supplies its own notices; font notices come verbatim from the bundled files.
const FONT_NOTICES := {
	"Figtree": "res://assets/template/fonts/Figtree-OFL.txt",
	"Noto Sans SC (runtime and loading screen)": "res://assets/template/fonts/NotoSansSC-OFL.txt",
	"Noto Sans (Vietnamese subset)": "res://assets/template/fonts/NotoSans-OFL.txt",
	"Sora": "res://assets/template/fonts/display/Sora-OFL.txt",
}

static func escape(value: String) -> String:
	return value.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace('"', "&quot;").replace("'", "&#39;")

static func section(title: String, notice: String) -> String:
	return "<section><h2>%s</h2><pre>%s</pre></section>\n" % [escape(title), escape(notice)]

func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() != 1:
		push_error("Usage: --script tools/generate_web_licenses.gd -- OUTPUT.html")
		quit(1)
		return
	var html := """<!doctype html>
<html lang="zh-CN">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>开源软件声明 / Open Source Licenses — The Grand Tour</title>
<style>
body { max-width: 64rem; margin: auto; padding: 1.5rem; background: #faf6ed; color: #29251f; font: 1rem/1.6 system-ui, sans-serif; }
a { color: #62442a; } section { border-top: 1px solid #cbbfae; margin-top: 2rem; }
pre { white-space: pre-wrap; overflow-wrap: anywhere; font: .875rem/1.6 ui-monospace, monospace; }
</style>
</head>
<body><main>
<a href="./">返回游戏 / Back to game</a>
<h1>开源软件声明 / Open Source Licenses</h1>
<p>The Grand Tour 使用以下开源引擎和字体。以下声明适用于所列组件，不代表游戏代码或美术素材采用相同许可。</p>
<p>The notices below cover the listed engine components and bundled fonts; they do not license the game's own code or artwork.</p>
<p>Godot notices are supplied by the official engine build used for this export, including its third-party notice inventory. This inventory may also describe components for other platforms. Font notices are reproduced from the repository's bundled license files.</p>
"""
	html += section("Godot Engine " + str(Engine.get_version_info().string) + " — MIT License", Engine.get_license_text())
	html += section("Godot third-party copyright and license references", JSON.stringify(Engine.get_copyright_info(), "\t"))
	var engine_licenses := Engine.get_license_info()
	var names := engine_licenses.keys()
	names.sort()
	for name: String in names:
		html += section("Godot third-party license: " + name, str(engine_licenses[name]))
	for family: String in FONT_NOTICES:
		var path: String = FONT_NOTICES[family]
		var notice := FileAccess.get_file_as_string(path)
		if notice.is_empty():
			push_error("Missing font license: " + path)
			quit(1)
			return
		html += section(family + " — SIL Open Font License 1.1", notice)
	html += "</main></body></html>\n"
	var output := FileAccess.open(args[0], FileAccess.WRITE)
	if output == null:
		push_error("Cannot write license page: " + args[0])
		quit(1)
		return
	output.store_string(html)
	output.close()
	print("Web license page ready: " + args[0])
	quit(0)
