import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PrivacyPolicyView extends StatelessWidget {
    final ScrollController? scrollController;
  const PrivacyPolicyView({Key? key, this.scrollController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('https://binteconsulting.com/aviso-privacidad.html'));

    return WebViewWidget(
      
      controller: controller,
    );
  }
}