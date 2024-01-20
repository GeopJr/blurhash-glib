# blurhash-glib

A GLib-based [blurhash](https://github.com/woltapp/blurhash) implementation partially ported from [fast-blurhash](https://github.com/mad-gooze/fast-blurhash) including further optimizations.

# Usage

```vala
public static Gdk.Pixbuf? blurhash_to_pixbuf (string blurhash, int width, int height) {
	uint8[]? data = Blurhash.decode_to_data (blurhash, width, height);
	if (data == null) return null;

	return new Gdk.Pixbuf.from_data (
		data,
		Gdk.Colorspace.RGB,
		true,
		8,
		width,
		height,
		4 * height
	);
}
```

# Building

```sh
$ meson setup builddir .
$ meson compile -C builddir
$ meson test -C builddir
$ meson install -C builddir
```

# Contributing

1. Read the [Code of Conduct](./CODE_OF_CONDUCT.md)
1. Fork it ( https://gitlab.gnome.org/GeopJr/blurhash-glib/-/forks/new )
1. Create your feature branch (git checkout -b my-new-feature)
1. Commit your changes (git commit -am 'Add some feature')
1. Push to the branch (git push origin my-new-feature)
1. Create a new Pull Request
