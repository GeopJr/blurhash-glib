struct BlurhashValidTest {
	public string blurhash;
	public bool valid;
	public int size_flag;
	public int num_x;
	public int num_y;
	public int size;
}

struct BlurhashDataTest {
	public string blurhash;
	public int width;
	public int height;
	public uint8[]? data;
}

const string DUMMY_BLURHASH = "LENdRdoffQoft7fQfQfQ0Ia#fQa#";
const uint8[] DUMMY_4_4 = {193, 194, 242, 255, 191, 192, 241, 255, 191, 192, 241, 255, 191, 192, 241, 255, 206, 207, 230, 255, 205, 206, 229, 255, 205, 206, 229, 255, 205, 206, 229, 255, 219, 219, 217, 255, 217, 218, 216, 255, 217, 218, 216, 255, 217, 218, 216, 255, 204, 205, 228, 255, 203, 204, 227, 255, 203, 204, 227, 255, 203, 204, 227, 255};
const uint8[] DUMMY_2_2 = {193, 194, 242, 255, 191, 192, 241, 255, 219, 219, 217, 255, 217, 218, 216, 255};

private void is_valid_blurhash_test () {
	BlurhashValidTest[] data = {
		{DUMMY_BLURHASH, true, 21, 4, 3, 12},
		{"tuba", false, 0, 0, 0, 0},
	};

	foreach (var test in data) {
		int size_flag;
		int num_x;
		int num_y;
		int size;

		assert (Blurhash.is_valid_blurhash (test.blurhash, out size_flag, out num_x, out num_y, out size) == test.valid);
		assert (size_flag == test.size_flag);
		assert (num_x == test.num_x);
		assert (num_y == test.num_y);
		assert (size == test.size);
	}
}

private void decode_to_data_test () {
	BlurhashDataTest[] data = {
		BlurhashDataTest () {
			blurhash = DUMMY_BLURHASH,
			width = 4,
			height = 4,
			data = DUMMY_4_4
		},
		BlurhashDataTest () {
			blurhash = DUMMY_BLURHASH,
			width = 2,
			height = 2,
			data = DUMMY_2_2
		},
		BlurhashDataTest () {
			blurhash = "tuba",
			width = 2,
			height = 2,
			data = null
		},
	};

	foreach (var test in data) {
		var decoded = Blurhash.decode_to_data (test.blurhash, test.width, test.height);
		if (decoded == null) {
			assert (decoded == test.data);
		} else {
			assert (decoded.length == test.data.length);
			for (var ii = 0; ii < decoded.length; ii++) {
				assert (decoded[ii] == test.data[ii]);
			}
		}
	}
}

private void register_blurhash_test () {
   Test.add_func ("/Blurhash/Blurhash.is_valid_blurhash", is_valid_blurhash_test);
   Test.add_func ("/Blurhash/Blurhash.decode_to_data", decode_to_data_test);
}
