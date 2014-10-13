part of katex_demo;


class KatexApp {

	InputElement inputElement = querySelector( '#input' );
	Element mathElement = querySelector( '#math' );
	ButtonElement permalinkButton = querySelector( '#permalink' );
	Katex katex = new Katex( loggingEnabled: true );

	KatexApp () {

		if ( window.location.hash != '' ) {

			getHash();

		}

		mathElement.setInnerHtml( inputElement.value );

		initElementEventListeners();

		reprocess();

	}

	void initElementEventListeners () {

		inputElement.onInput.listen(( e ) {

			mathElement.setInnerHtml( inputElement.value );

			reprocess();

			});

		permalinkButton.onClick.listen(( e ) {

			var encodedValue = Uri.encodeFull( inputElement.value );

			window.location.hash = '#text=' + encodedValue;

			});

		window.onHashChange.listen(( HashChangeEvent e ) {

			getHash();

			reprocess();

			});

	}

	void getHash () {

		var hash = window.location.hash;
		var hashValue = Uri.decodeFull( hash.split('#text=')[1] );

		inputElement.value = hashValue;
		mathElement.setInnerHtml( hashValue );

	}

	void reprocess () {
		
		try {

			katex.render( inputElement.value,  mathElement );

		} on ParseError catch ( e ) {

			window.console.error( e );

		} catch ( e ) {

			window.console.error( e );

		}
	}
}