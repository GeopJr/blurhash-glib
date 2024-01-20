struct Base83Test {
    public int decoded;
    public int length;
    public string encoded;
}

private void encode_test () {
    Base83Test[] data = {
        {0, 0, ""},
        {6888, 4, "00~~"},
        {100, 2, "1H"}
    };

    foreach (var test in data) {
        assert (Blurhash.Base83.encode (test.decoded, test.length) == test.encoded);
    }
}

private void decode_test () {
    Base83Test[] data = {
        {0, 0, ""},
        {6888, 0, "00~~"},
        {31837176, 0, "tuba"},
        {100, 0, "1H"}
    };

    foreach (var test in data) {
        assert (Blurhash.Base83.decode (test.encoded) == test.decoded);
    }
}

private void register_base83_test () {
   Test.add_func ("/Blurhash/Base83.encode", encode_test);
   Test.add_func ("/Blurhash/Base83.decode", decode_test);
}
