import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/error_view.dart';
import '../../widgets/no_internet_view.dart';
import '../asset_registration/presentation/screens/asset_form_screen.dart';
import 'webview_controller.dart';

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewControllerWrapper _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewControllerWrapper();
    _controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  // ─── Android back button ──────────────────────────────────────────────────
  Future<bool> _onWillPop() async {
    final consumed = await _controller.handleAndroidBackButton();
    return !consumed;
  }

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(AppConstants.appName),
          elevation: 0,
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const AssetFormScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Offline'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Stack(
      children: [
        // ── WebView — bare Positioned.fill, nothing intercepting touches ─────
        // WebViewWidget is a native platform view: it must receive raw touch
        // events directly. Any Flutter scroll/gesture widget above it will win
        // the gesture arena and prevent native WebView scrolling.
        Positioned.fill(
          child: WebViewWidget(controller: _controller.webViewController),
        ),

        // ── Loading progress bar ─────────────────────────────────────────────
        if (_controller.status == WebViewStatus.loading)
          _buildLoadingIndicator(),

        // ── Error overlay ────────────────────────────────────────────────────
        if (_controller.status == WebViewStatus.error)
          ErrorView(
            message: _controller.errorMessage,
            onRetry: _controller.reload,
          ),

        // ── Offline overlay ──────────────────────────────────────────────────
        if (_controller.status == WebViewStatus.offline)
          NoInternetView(onRetry: _controller.reload),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    final progress = _controller.loadingProgress;
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Column(
        children: [
          LinearProgressIndicator(
            value: progress > 0 && progress < 100 ? progress / 100 : null,
            backgroundColor: Colors.white.withValues(alpha: 0.3),
            color: AppTheme.accentColor,
            minHeight: 3,
          ),
          // Full-screen splash on very first load only
          if (progress < 30)
            Container(
              height: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom -
                  3,
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withValues(alpha: 0.35),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'IN',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      AppConstants.appName,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryColor,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 48),
                    const SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: AppTheme.accentColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
