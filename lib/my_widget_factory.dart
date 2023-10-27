import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:html_view/table/table_factory.dart';

import 'latex/latex_factory.dart';

class MyWidgetFactory extends WidgetFactory
    with ScrollableTableFactory, LatexFactory {
  @override
  String getListMarkerText(String type, int i) {
    if (type == 'dash') {
      return '— ';
    }
    return super.getListMarkerText(type, i);
  }
}
