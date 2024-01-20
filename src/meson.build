sources = files(
    'Base83.vala',
    'Blurhash.vala',
)

blurhash_lib = library(
    api_name,
    [sources],
    vala_gir: gir_name,
    dependencies: deps,
    vala_args: vala_args,
    install: true,
    install_dir: [true, true, true, g_ir_compiler.found()]
)
blurhash_dep = declare_dependency(include_directories: include_directories('.'), link_with: blurhash_lib)

if g_ir_compiler.found()
	custom_target('blurhash-glib typelib',
		command: [g_ir_compiler, '--output', '@OUTPUT@', meson.current_build_dir() / gir_name],
		output: typelib_name,
		depends: blurhash_lib,
		install: true,
		install_dir: get_option('libdir') / 'girepository-1.0'
	)
endif
