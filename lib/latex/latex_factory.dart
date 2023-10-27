import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

mixin LatexFactory on WidgetFactory {
  @override
  void parse(BuildTree tree) {
    super.parse(tree);
    if (tree.element.localName == 'tex') {
      _registerLatexOp(tree);
    }
  }

  _registerLatexOp(BuildTree tree) {
    BuildOp math = BuildOp(onParsed: (tree) {
      return tree.sub()
        ..prepend(
          WidgetBit.inline(
            tree,
            ColoredBox(
              color: Colors.white,
              child: Math.tex(
                tree.element.text,
                textStyle:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                onErrorFallback: (err) {
                  print('渲染异常:${err.message}');
                  return Text(
                    err.message,
                    style: TextStyle(color: Colors.red),
                  );
                },
              ),
            ),
          ),
        );
    });
    tree.register(math);
  }
}
