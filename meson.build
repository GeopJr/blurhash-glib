project('blurhash-glib', ['vala', 'c'], version: '0.1.0', license: 'BSD-2-Clause')

api_version = '1'
g_ir_compiler = find_program('g-ir-compiler', required: false)
pkgconfig = import('pkgconfig')
api_name = 'blurhash-glib-' + api_version
gir_name = 'blurhash-' + api_version + '.gir'
typelib_name = api_name + '.typelib'
cc = meson.get_compiler('c')

if cc.get_id () == 'clang'
	add_project_arguments('-Wno-incompatible-function-pointer-types', language: 'c')
endif

vala_args = []
if get_option('debug') == true
	vala_args += ['--ccode', '--debug']
endif

pkgconfig_deps = [
	dependency('glib-2.0'),
	dependency('gobject-2.0'),
]

deps = [
	pkgconfig_deps,
	cc.find_library('m', required: true)
]

subdir('src')
subdir('tests')

pkgconfig.generate(
	blurhash_lib,
	subdirs: api_name,
	version: api_version,
	name: 'blurhash-glib',
	filebase: api_name,
	requires: pkgconfig_deps,
	description: 'GLib-based implementation of Blurhash'
)
