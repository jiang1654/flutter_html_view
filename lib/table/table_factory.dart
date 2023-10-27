import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:html/dom.dart' as dom;

mixin ScrollableTableFactory on WidgetFactory {
  @override
  void parse(BuildTree meta) {
    switch (meta.element.localName) {
      case 'table':
        meta.register(BuildOp(
          onRenderBlock: (meta, widgets) => ScrollableTableFromHtml(
            element: meta.element,
            child: widgets,
          ),
        ));
    }
    return super.parse(meta);
  }
}

class ScrollableTableFromHtml extends StatelessWidget {
  const ScrollableTableFromHtml({required this.child, required this.element});

  final Widget child;
  final dom.Element element;

  @override
  Widget build(BuildContext context) {
    final double width = context.size!.width;

    return _columnCount(element) <= 2
        ? child
        : SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: LimitedBox(maxWidth: width * 2, child: child),
          );
  }

  int _columnCount(dom.Element element) {
    final List<dom.Element> tableRows = element.getElementsByTagName('tr');

    return _getCountOrNullByTag(tableRows, 'th') ??
        _getCountOrNullByTag(tableRows, 'td') ??
        0;
  }

  int? _getCountOrNullByTag(List<dom.Element> tableRows, String tag) {
    final int? count = tableRows.first.getElementsByTagName(tag).length;
    return count != 0 ? count : null;
  }
}
