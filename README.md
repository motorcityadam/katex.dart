katex.dart
==========

Fast math typesetting for the web, ported to Dart.

## Overview

katex.dart is a port of the [KaTeX](https://github.com/Khan/KaTeX) project codebase which was originally developed and released by Kahn Academy. As such, credit should be provided to them for the inspiraton and current design principals on which this project is based.

A very detailed description is provided by the KaTeX project:

KaTeX is a fast, easy-to-use JavaScript library for TeX math rendering on the web.

 * **Fast:** KaTeX renders its math synchronously and doesn't need to reflow the page. See how it compares to a competitor in [this speed test](http://jsperf.com/katex-vs-mathjax/).
 * **Print quality:** KaTeX’s layout is based on Donald Knuth’s TeX, the gold standard for math typesetting.
 * **Self contained:** KaTeX has no dependencies and can easily be bundled with your website resources.
 * **Server side rendering:** KaTeX produces the same output regardless of browser or environment, so you can pre-render expressions using Node.js and send them as plain HTML.

## Motivation

The KaTeX (KaTeX.js) project provides fast typsetting of mathematical expressions in the browser, however, there are some areas of interest that the katex.dart project aims to explore which may or may not be commonly shared by the KaTeX.js project:

1. Adopting Polymer and Shadow DOM technologies to handle the presentation of the mathematical expressions.
2. Providing better maintainability and extensibility than KaTeX.js through the class-based architecture and optional typing interface afforded by the Dart language.
3. Providing better performance than KaTeX.js through code executed on the Dart VM (currently only supported through the use of the Dartium web browser) and possibly through the transpiled JavaScript code produced by Dart's Dart2JS compiler.
4. Matching the functionality and features provided by the [MathJax](https://github.com/mathjax/mathjax) project as, currently, KaTeX.js does not support as many features, symbols and mathematical functions as MathJax.
5. Adopting MathML as the native interface for outputing both the presentation and semantics of a mathematical expression remains a key area of interest for future work on this project. However, as of yet, browser support for MathML remains [critically low](http://caniuse.com/#search=MathML).

## Status

Please note that this project is under heavy development and API changes are very probable while this package is in beta. Currently, much more work needs to be accomplished to bring the benefits of Dart's class-based structure, typing interface and the promise of increased execution speed under the Dart VM to this project.

The only browser that can currently run this code is Dartium which only ships with the Dart SDK. This will be true while this project is in beta.

Server-side rendering is not yet supported, but it is planned.

## Demonstration Application and Benchmarks

TODO

## Usage

Include the `main.dart` and `katex.min.css` files on the page.

The `main.dart` file is **not** provided by the project and is not required to be named `main.dart`. In this example, the `main.dart` file contains the code necessary to import the `katex.dart` package, create the [Katex] instance and render the formatted expression to an [Element]. See the Dart code provided below.

```html
<link rel="stylesheet" href="/path/to/katex.min.css">
<script type="application/dart" src="main.dart"></script>
```

Execute the `katex.render` method with a TeX-formatted mathematical expression [String] and an [Element] to append the output into:

```dart
import 'package:katex/katex.dart';

Katex katex = new Katex( loggingEnabled: false );
katex.render( "c = \\pm\\sqrt{a^2 + b^2}", element );
```

The `loggingEnabled` argument can be set to `true` to enable key activity logging in the `katex.parser` and `katex.lexer` libraries.

## Browser Support

In general, the most current and prior major release of any given browser will be supported by this project. The KaTeX.js project (as a project goal) seems to support older browsers than this project will ultimately support. If older browser support is needed, please consider the use of the KaTeX.js project.

TODO
    
## Build Notes

TODO

## Running the Demonstration Application Locally

To run the example application, run the following command from the repository root of the project:

    pub serve

After the command completes, visit the following address in a web browser of choice:

`http://localhost:8080`

Please note that the Dartium web browser that ships with the Dart SDK can run the Dart code natively (as it includes the Dart VM), but that all other browsers must have the Dart code transpiled to JavaScript. When using the `pub serve` command, the Dart2JS compiler included with the Dart SDK performs the transpiling automatically. However, there may be some noticable "lag" in loading the example application while the Dart code is being transformed.

## Contributing

Thank you for your consideration! Please review the [Contributing Guidelines][contributing].

If your primary interest is developing this project in JavaScript, please consider [contributing](https://github.com/Khan/KaTeX/blob/master/CONTRIBUTING.md) to the KaTeX.js project. Please be mindful of their procedures and goals as, in time, this project's requirements may be substaintially different.

[contributing]: https://github.com/adamjcook/katex.dart/blob/master/CONTRIBUTING.md
