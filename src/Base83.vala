namespace Blurhash {
	/**
	* Base83 encoding and decoding for use with {@link Blurhash}
	*/
	public class Base83 {
		const char[] CHARACTERS = {
			'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', '#', '$', '%', '*', '+', ',', '-', '.', ':', ';', '=', '?', '@', '[', ']', '^', '_', '{', '|', '}', '~'
		};

		public static string encode (int value, int length) {
			StringBuilder res = new StringBuilder ();

			for (int i = 1; i <= length; i++) {
				int digit = (int) (value / Math.pow (83, length - i) % 83);
				res.append_c (CHARACTERS[digit]);
			}

			return res.str;
		}

		public static int decode (string value) {
			int res = 0;

			for (int i = 0; i < value.length; i++) {
				char character = value[i];

				int index = -1;
				for (int j = 0; j < 83; j++) {
					if (CHARACTERS[j] == character) {
						index = j;
						break;
					}
				}
				if (index == -1) return 0;

				res = res * 83 + index;
			}

			return res;
		}
	}
}
