import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:jovial_svg/jovial_svg.dart';
import 'my_widget_factory.dart';
import 'packages/flutter_html_math.dart';
import 'packages/flutter_html_svg.dart';
import 'packages/flutter_html_table.dart';

class HtmlView extends StatefulWidget {
  final String data;
  final OnLoadingBuilder? onLoadingBuilder;
  const HtmlView({super.key, required this.data, this.onLoadingBuilder});

  @override
  State<HtmlView> createState() => _HtmlViewState();
}

class _HtmlViewState extends State<HtmlView> {
  @override
  Widget build(BuildContext context) {
    if (!widget.data.contains('<tr>')) {
      debugPrint('使用第一种HtmlView渲染:${widget.data}');
      return _buildHtmlView(containsFormula(widget.data),
          onMathErrorBuilder: (parsedTex, exception, exceptionWithType) {
        debugPrint('公式渲染失败1:$exception');
        debugPrint('公式渲染文本1:$parsedTex');
        if (exception.contains(r'\lnt')) {
          return Math.tex(parsedTex.replaceAll(r'\lnt', 'ln t'),
              mathStyle: MathStyle.display,
              textStyle: TextStyle(
                  fontSize: 13,
                  color: Colors.black,
                  fontWeight: FontWeight.bold));
        }
        return Text(
          parsedTex,
          style: TextStyle(color: Colors.black),
        );
      });
    } else {
      debugPrint('使用第二种HtmlView渲染');
      return _buildHtml2View(
        containsFormula(widget.data),
        onErrorBuilder: (context, element, error) {
          debugPrint('公式渲染失败2:$error');
          debugPrint('公式渲染文本2:$element');
          return Text(
            error,
            style: TextStyle(color: Colors.black),
          );
        },
        onMathErrorBuilder: (parsedTex, exception, exceptionWithType) {
          debugPrint('公式渲染失败2:$exception');
          debugPrint('公式渲染文本2:$parsedTex');
          return Text(
            parsedTex,
            style: TextStyle(color: Colors.black),
          );
        },
      );
    }
  }

  Widget _buildHtmlView(htmlData, {OnMathErrorBuilder? onMathErrorBuilder}) {
    return Html(
      data: htmlData,
      extensions: [
        TableHtmlExtension(),
        MathHtmlExtension(onMathErrorBuilder: onMathErrorBuilder),
        SvgHtmlExtension(),
        TagExtension(
            tagsToExtend: {"img"},
            builder: (extensionContext) {
              return _buildHtml2View(extensionContext.element?.outerHtml);
            }),
        TagExtension(
            tagsToExtend: {"tex"},
            builder: (extensionContext) {
              return _buildMathTex(extensionContext, onErrorFallback: (e) {
                return Text(
                  extensionContext.innerHtml,
                  style: TextStyle(color: Colors.black),
                );
              });
            }),
      ],
      style: {
        "p": Style(
          fontSize: FontSize(16),
        ),
        "table": Style(
          height: Height.auto(),
          width: Width.auto(),
        ),
        "tr": Style(
          height: Height.auto(),
          width: Width.auto(),
        ),
        "th": Style(
          padding: HtmlPaddings.all(6),
          height: Height.auto(),
          border: const Border(
            left: BorderSide(color: Colors.black, width: 0.5),
            bottom: BorderSide(color: Colors.black, width: 0.5),
            top: BorderSide(color: Colors.black, width: 0.5),
          ),
        ),
        "td": Style(
          padding: HtmlPaddings.all(6),
          height: Height.auto(),
          border: const Border(
            left: BorderSide(color: Colors.black, width: 0.5),
            bottom: BorderSide(color: Colors.black, width: 0.5),
            top: BorderSide(color: Colors.black, width: 0.5),
            right: BorderSide(color: Colors.black, width: 0.5),
          ),
        ),
        "col": Style(
          height: Height.auto(),
          width: Width.auto(),
        ),
      },
    );
  }

  Widget _buildHtml2View(htmlStr,
      {OnErrorBuilder? onErrorBuilder,
      OnMathErrorBuilder? onMathErrorBuilder}) {
    return HtmlWidget(
      htmlStr,
      onErrorBuilder: (context, element, error) {
        return Text(
          error,
          style: TextStyle(color: Colors.black),
        );
      },
      customWidgetBuilder: (element) {
        if (element.localName == 'svg') {
          final ScalableImage si = ScalableImage.fromSvgString(
            element.outerHtml,
          );
          return ScalableImageWidget(si: si);
        } else if (element.localName == 'math') {
          debugPrint('Html2View math:${element.outerHtml}');
          return _buildHtmlView(element.outerHtml,
              onMathErrorBuilder: onMathErrorBuilder);
        }
        return null;
      },
      onLoadingBuilder: widget.onLoadingBuilder,
      factoryBuilder: () {
        return MyWidgetFactory();
      },
      customStylesBuilder: (element) {
        switch (element.localName) {
          case 'table':
            return {
              'border': '0.5px solid',
              'border-collapse': 'collapse',
              'text-align': 'center'
            };
          case 'tr':
            return {'text-align': 'center'};
          case 'td':
            return {'border': '0.5px solid', 'text-align': 'center'};
        }

        return null;
      },
    );
  }

  String containsFormula(String text) {
    RegExp latexPattern = RegExp(
        r'''\\\(.*?\\\)|(\$\$[\s\S]*?\$\$)|(\$(.*?)\$)|(\\\[[\s\S]*?\\\])''');
    String processedHtml = text.replaceAllMapped(latexPattern, (match) {
      if (match.group(0) != null) {
        String latexExpression = match
                .group(0)
                ?.replaceAll('&nbsp;', ' ')
                .replaceAll('&amp;', r'&')
                .replaceAll('<br>', '\n') ??
            '';
        String mathStr;
        if (latexExpression.substring(0, 2) == r'$$' ||
            latexExpression.substring(0, 2) == r'\(' ||
            latexExpression.substring(0, 2) == r'\[') {
          mathStr =
              '<tex>${latexExpression.substring(2, latexExpression.length - 2)}</tex>';
        } else if (latexExpression.substring(0, 1) == r'$') {
          mathStr =
              '<tex>${latexExpression.substring(1, latexExpression.length - 1)}</tex>';
        } else {
          mathStr = '<tex>$latexExpression</tex>';
        }
        return mathStr;
      } else {
        return '';
      }
    });
    return processedHtml;
  }

  Widget _buildMathTex(ExtensionContext extensionContext,
      {required OnErrorFallback onErrorFallback}) {
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Math.tex(extensionContext.innerHtml.replaceAll('&amp;', r'&'),
            mathStyle: MathStyle.display,
            textStyle:
                extensionContext.styledElement?.style.generateTextStyle(),
            onErrorFallback: onErrorFallback));
  }
}
