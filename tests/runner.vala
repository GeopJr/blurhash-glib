void main (string[] args) {
	Test.init (ref args);

	register_base83_test ();
	register_blurhash_test ();

	Test.run ();
}
