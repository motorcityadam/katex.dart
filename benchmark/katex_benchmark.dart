library katex_benchmark;

import 'dart:html';

import 'package:benchmark_harness/benchmark_harness.dart';

import 'package:katex/katex.dart';


Element math;
String formula;
Katex katex;

class KatexBenchmark extends BenchmarkBase {
  const KatexBenchmark() : super('Template');

  static void main() {
    new KatexBenchmark().report();
  }

  void run() {

    katex.render( formula, math );
//    math.outerWidth;

  }

  void setup() {
    katex = new Katex();
    math = querySelector( '#math' );
    formula = '\\dfrac{-b \\pm \\sqrt{b^2 - 4ac}}{2a}';
  }

  void teardown() {
    math.setInnerHtml('');
  }
}

main() {
  KatexBenchmark.main();
}