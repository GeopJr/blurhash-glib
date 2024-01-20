namespace Blurhash {
	struct AverageColor {
		int r;
		int g;
		int b;
	}

	struct ColorSRGB {
		float r;
		float g;
		float b;
	}

	// Decodes a Base83 string partially from `start` to `end`.
	// WARNING: sanitize start and end manually, this is only used
	//			here and only on valid blurhashes.
	private static int decode_partial (string str, int start, int end) {
		if (start > end) return 0;

		int str_length = str.length;
		if (end >= str_length) end = str_length;

		return Base83.decode (str.slice (start, end));
	}

	private static int linear_to_srgb (float value) {
		float v = value.clamp (0f, 1f);
		if (v <= 0.0031308) return (int) (v * 12.92f * 255 + 0.5);

		return (int) ((1.055 * Math.powf (v, 1 / 2.4f) - 0.055) * 255 + 0.5);
	}

	private static float srgb_to_linear (int value) {
		float v = value / 255f;
		if (v <= 0.04045) return v / 12.92f;

		return Math.powf ((v + 0.055f) / 1.055f, 2.4f);
	}

	private static float sign_pow (float value, float exp) {
		return Math.copysignf (Math.powf (Math.fabsf (value), exp), value);
	}

	/**
	 * Check if a blurhash is valid and get the relevant metadata.
	 *
	 * @param blurhash the blurhash to be tested
	 * @param size_flag
	 * @param num_x
	 * @param num_y
	 * @param size
	 */
	public static bool is_valid_blurhash (string blurhash, out int size_flag, out int num_x, out int num_y, out int size) {
		size_flag = 0;
		num_y = 0;
		num_x = 0;
		size = 0;

		int hash_length = blurhash.length;
		if (hash_length < 6) return false;

		size_flag = decode_partial (blurhash, 0, 1);
		num_y = (int) Math.floorf (size_flag / 9) + 1;
		num_x = (size_flag % 9) + 1;
		size = num_x * num_y;

		if (hash_length != 4 + 2 * size) return false;
		return true;
	}

	private static AverageColor get_blurhash_average_color (string blurhash) {
		int val = decode_partial (blurhash, 2, 6);
		return { val >> 16, (val >> 8) & 255, val & 255 };
	}

	private static ColorSRGB decode_ac (int value, float maximum_value) {
		int quant_r = (int)Math.floorf (value / (19 * 19));
		int quant_g = (int)Math.floorf (value / 19) % 19;
		int quant_b = (int)value % 19;

		return ColorSRGB () {
			r = sign_pow (((float)quant_r - 9) / 9, 2.0f) * maximum_value,
			g = sign_pow (((float)quant_g - 9) / 9, 2.0f) * maximum_value,
			b = sign_pow (((float)quant_b - 9) / 9, 2.0f) * maximum_value
		};
	}

	/**
	 * Decode a blurhash into data.
	 *
	 * Example usage:
	 * {{{
	 *   public static Gdk.Pixbuf? blurhash_to_pixbuf (string blurhash, int width, int height) {
	 *		uint8[]? data = Blurhash.decode_to_data (blurhash, width, height);
	 *		if (data == null) return null;
	 *
	 *		return new Gdk.Pixbuf.from_data (
	 *			data,
	 *			Gdk.Colorspace.RGB,
	 *			true,
	 *			8,
	 *			width,
	 *			height,
	 *			4 * height
	 *		);
	 *	}
	 * }}}
	 *
	 * @param blurhash the blurhash to be tested
	 * @param width the desired width
	 * @param height the desired height
	 * @param punch adjust contrast (> 1)
	 * @param has_alpha whether it should have an alpha channel
	 */
	public static uint8[]? decode_to_data (string blurhash, int width, int height, int punch = 1, bool has_alpha = true) {
		int bytes_per_row = width * (has_alpha ? 4 : 3);
		uint8[] res = new uint8[bytes_per_row * height];

		int size_flag;
		int num_y;
		int num_x;
		int size;

		if (!is_valid_blurhash (blurhash, out size_flag, out num_x, out num_y, out size)) return null;
		if (punch < 1) punch = 1;

		float maximum_value = ((decode_partial (blurhash, 1, 2) + 1) / 166f) * punch;
		float[] colors = new float[size * 3];

		AverageColor average_color = get_blurhash_average_color (blurhash);
		colors[0] = srgb_to_linear (average_color.r);
		colors[1] = srgb_to_linear (average_color.g);
		colors[2] = srgb_to_linear (average_color.b);

		for (int i = 1; i < size; i++) {
			int value = decode_partial (blurhash, 4 + i * 2, 6 + i * 2);

			ColorSRGB color = decode_ac (value, maximum_value);
			colors[i * 3] = color.r;
			colors[i * 3 + 1] = color.g;
			colors[i * 3 + 2] = color.b;
		}

		for (int y = 0; y < height; y++) {
			float yh = (float) (Math.PI * y) / height;
			for (int x = 0; x < width; x++) {
				float r = 0;
				float g = 0;
				float b = 0;
				float xw = (float) (Math.PI * x) / width;

				for (int j = 0; j < num_y; j++) {
					float basis_y = Math.cosf (yh * j);
					for (int i = 0; i < num_x; i++) {
						float basis = Math.cosf (xw * i) * basis_y;

						int color_index = (i + j * num_x) * 3;
						r += colors[color_index] * basis;
						g += colors[color_index + 1] * basis;
						b += colors[color_index + 2] * basis;
					}
				}

				int pixel_index = 4 * x + y * bytes_per_row;
				res[pixel_index] = (uint8) linear_to_srgb (r);
				res[pixel_index + 1] = (uint8) linear_to_srgb (g);
				res[pixel_index + 2] = (uint8) linear_to_srgb (b);

				if (has_alpha)
					res[pixel_index + 3] = (uint8) 255;
			}
		}

		return res;
	}

	// WIP but also I don't really care about it myself
	// if anyone wants to take over, feel free to.
	//  private static int encode_dc (ColorSRGB rgb) {
	//  	int rounded_r = linear_to_srgb (rgb.r);
	//  	int rounded_g = linear_to_srgb (rgb.g);
	//  	int rounded_b = linear_to_srgb (rgb.b);
	//  	return (rounded_r << 16) + (rounded_g << 8) + rounded_b;
	//  }

	//  private static int encode_ac (ColorSRGB rgb, float maximum_value) {
	//  	int quant_r = (int)Math.fmaxf(0f, Math.fminf(18f, Math.floorf(sign_pow (rgb.r / maximum_value, 0.5f) * 9f + 9.5f)));
	//  	int quant_g = (int)Math.fmaxf(0f, Math.fminf(18f, Math.floorf(sign_pow (rgb.g / maximum_value, 0.5f) * 9f + 9.5f)));
	//  	int quant_b = (int)Math.fmaxf(0f, Math.fminf(18f, Math.floorf(sign_pow (rgb.b / maximum_value, 0.5f) * 9f + 9.5f)));

	//  	return quant_r * 19 * 19 + quant_g * 19 + quant_b;
	//  }

	//  private static ColorSRGB multiply_basis_function (int x_component, int y_component, int width, int height, uint8[] pixels, int bytes_per_row) {
	//  	float r = 0, g = 0, b = 0;
	//  	float normalisation = (x_component == 0 && y_component == 0) ? 1 : 2;

	//  	for(int y = 0; y < height; y++) {
	//  		for(int x = 0; x < width; x++) {
	//  			float basis = (float) (Math.cos ((Math.PI * x_component * x / width)) * Math.cos ((Math.PI * y_component * y / height)));
	//  			r += basis * srgb_to_linear (pixels[3 * x + 0 + y * bytes_per_row]);
	//  			g += basis * srgb_to_linear (pixels[3 * x + 1 + y * bytes_per_row]);
	//  			b += basis * srgb_to_linear (pixels[3 * x + 2 + y * bytes_per_row]);
	//  		}
	//  	}

	//  	float scale = normalisation / (width * height);    
	//  	return ColorSRGB () {
	//  		r = r * scale,
	//  		g = g * scale,
	//  		b = b * scale
	//  	};
	//  }

	//  public string? encode (int x_components, int y_components, int width, int height, uint8[] pixels, int bytes_per_row) {
	//  	if(x_components < 1 || x_components > 9 || y_components < 1 || y_components > 9) return null;

	//  	int total_items = y_components * x_components;
	//  	ColorSRGB[] factors = new ColorSRGB[total_items];
	//  	for(int y = 0; y < y_components; y++) {
	//  		for(int x = 0; x < x_components; x++) {
	//  			factors[(y * x_components) + x] = multiply_basis_function (x, y, width, height, pixels, bytes_per_row);
	//  		}
	//  	}

	//  	int size_flag = (x_components - 1) + (y_components - 1) * 9;
	//  	string res = Base83.encode (size_flag, 1);

	//  	float maximum_value;
	//  	if(total_items > 1) {
	//  		float actual_maximum_value = 0;
	//  		for(int y = 1; y < total_items; y++) {
	//  			actual_maximum_value = Math.fmaxf(Math.fabsf(factors[y].r), actual_maximum_value);
	//  			actual_maximum_value = Math.fmaxf(Math.fabsf(factors[y].g), actual_maximum_value);
	//  			actual_maximum_value = Math.fmaxf(Math.fabsf(factors[y].b), actual_maximum_value);
	//  		}

	//  		int quantised_maximum_value = (int)Math.fmaxf(0, Math.fminf(82, Math.floorf(actual_maximum_value * 166 - 0.5f)));
	//  		maximum_value = ((float) quantised_maximum_value + 1) / 166;
	//  		res += Base83.encode (quantised_maximum_value, 1);
	//  	} else {
	//  		maximum_value = 1f;
	//  		res += "0";
	//  	}

	//  	res += Base83.encode (encode_dc (factors[0]), 4);
	//  	for(int y = 1; y < total_items; y++) {
	//  		res += Base83.encode (encode_ac (factors[y], maximum_value), 2);
	//  	}

	//  	return res;
	//  }
}
