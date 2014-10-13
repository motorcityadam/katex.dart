library katex.token;

// TODO(adamjcook): Add class description.
class Token {

  final String text;
  final dynamic data;
  final num position;

  Token(
    { String text: '',
      dynamic data: '',
      num position: 0 } )
  : this._init(
    text: text,
    data: data,
    position: position );

  Token._init(
    { this.text,
      this.data,
      this.position } ) { }

}