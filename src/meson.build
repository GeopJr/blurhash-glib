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
