library katex.parse_error;


// TODO(adamjcook): Add class description.
class ParseError implements Exception {

	final String message;

	const ParseError([this.message = '']);

	String toString() => "ParseError: $message";

}