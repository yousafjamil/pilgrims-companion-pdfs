import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  final String url;
  final String title;

  const WebViewScreen({
    super.key,
    required this.url,
    required this.title,
  });

  @override
  State<WebViewScreen> createState() =>
      _WebViewScreenState();
}

class _WebViewScreenState
    extends State<WebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  int _loadingProgress = 0;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            setState(() {
              _loadingProgress = progress;
            });
          },
          onPageStarted: (_) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (_) {
            setState(() => _isLoading = false);
          },
          onWebResourceError: (error) {
            setState(() => _isLoading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => _controller.reload(),
          ),
          IconButton(
            icon: const Icon(Icons.home_rounded),
            onPressed: () {
              _controller.loadRequest(
                Uri.parse('https://prh.gov.sa'),
              );
            },
          ),
        ],
        bottom: _isLoading
            ? PreferredSize(
                preferredSize:
                    const Size.fromHeight(3),
                child: LinearProgressIndicator(
                  value: _loadingProgress / 100,
                  backgroundColor:
                      Colors.white.withOpacity(0.3),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(
                    Colors.white,
                  ),
                ),
              )
            : null,
      ),
      body: Column(
        children: [
          Expanded(
            child: WebViewWidget(
              controller: _controller,
            ),
          ),

          // Navigation Bar
          Container(
            decoration: BoxDecoration(
              color:
                  Theme.of(context).cardTheme.color,
              boxShadow: [
                BoxShadow(
                  color:
                      Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            padding: EdgeInsets.fromLTRB(
              8,
              8,
              8,
              MediaQuery.of(context).padding.bottom +
                  8,
            ),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_rounded,
                  ),
                  onPressed: () async {
                    if (await _controller
                        .canGoBack()) {
                      _controller.goBack();
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.arrow_forward_ios_rounded,
                  ),
                  onPressed: () async {
                    if (await _controller
                        .canGoForward()) {
                      _controller.goForward();
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.refresh_rounded,
                  ),
                  onPressed: () =>
                      _controller.reload(),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                  ),
                  onPressed: () =>
                      Navigator.pop(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}