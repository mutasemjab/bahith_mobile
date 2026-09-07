import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_colors.dart';
import 'app_error_view.dart';
import 'loading_widget.dart';

/// Downloads a remote PDF to a temp file and renders it in-app. Reusable
/// as a standalone page ([PdfViewerPage]) or embedded inline (e.g. inside
/// a lesson screen's tab view via [PdfViewerBody] directly).
class PdfViewerBody extends StatefulWidget {
  final String url;

  const PdfViewerBody({super.key, required this.url});

  @override
  State<PdfViewerBody> createState() => _PdfViewerBodyState();
}

class _PdfViewerBodyState extends State<PdfViewerBody> {
  String? _localPath;
  String? _error;

  @override
  void initState() {
    super.initState();
    _download();
  }

  Future<void> _download() async {
    try {
      final dir = await getTemporaryDirectory();
      final fileName = widget.url.split('/').last;
      final file = File('${dir.path}/$fileName');
      if (!await file.exists()) {
        await Dio().download(widget.url, file.path);
      }
      if (!mounted) return;
      setState(() => _localPath = file.path);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'تعذّر تحميل الملف، تحقق من اتصالك بالإنترنت');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return AppErrorView(
        message: _error!,
        onRetry: () {
          setState(() => _error = null);
          _download();
        },
      );
    }
    if (_localPath == null) return const LoadingWidget();
    return PDFView(
      filePath: _localPath!,
      enableSwipe: true,
      swipeHorizontal: false,
      autoSpacing: true,
      pageFling: true,
    );
  }
}

/// Full-screen wrapper around [PdfViewerBody] with an app bar and an
/// "open externally" fallback action.
class PdfViewerPage extends StatelessWidget {
  final String url;
  final String title;

  const PdfViewerPage({super.key, required this.url, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new_rounded),
            onPressed: () =>
                launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
          ),
        ],
      ),
      backgroundColor: AppColors.navy,
      body: PdfViewerBody(url: url),
    );
  }
}
