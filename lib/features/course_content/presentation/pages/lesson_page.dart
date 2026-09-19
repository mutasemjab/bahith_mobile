import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_windowmanager_plus/flutter_windowmanager_plus.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../../core/cubit/resource_state.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/pdf_viewer_page.dart';
import '../../domain/entities/course_content_entity.dart';
import '../cubit/lesson_detail_cubit.dart';

/// Plays a lesson's video and/or shows its PDF. Applies `FLAG_SECURE` on
/// Android for the entire time this screen is up — for every lesson,
/// regardless of free/paid — so course content can't be screenshotted or
/// screen-recorded, clearing it again only once the student leaves.
class LessonPage extends StatefulWidget {
  final int lessonId;

  /// Where to resume video playback from, in seconds — taken from the
  /// course's `watch_positions` map so re-opening a lesson picks up where
  /// the student left off instead of restarting from zero.
  final int? resumeSeconds;
  const LessonPage({super.key, required this.lessonId, this.resumeSeconds});

  @override
  State<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends State<LessonPage> {
  late final LessonDetailCubit _cubit = sl<LessonDetailCubit>()
    ..load(widget.lessonId);
  bool _secureApplied = false;

  @override
  void initState() {
    super.initState();
    _applySecure();
  }

  Future<void> _applySecure() async {
    if (!Platform.isAndroid) return;
    await FlutterWindowManagerPlus.addFlags(
      FlutterWindowManagerPlus.FLAG_SECURE,
    );
    _secureApplied = true;
  }

  Future<void> _clearSecure() async {
    if (!Platform.isAndroid || !_secureApplied) return;
    await FlutterWindowManagerPlus.clearFlags(
      FlutterWindowManagerPlus.FLAG_SECURE,
    );
    _secureApplied = false;
  }

  @override
  void dispose() {
    _clearSecure();
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<LessonDetailCubit, ResourceState<LessonDetailEntity>>(
        bloc: _cubit,
        builder: (context, state) {
          if (state is ResourceLoading) {
            return Scaffold(
              appBar: AppBar(title: const Text('الدرس')),
              body: const LoadingWidget(),
            );
          }
          if (state is ResourceError<LessonDetailEntity>) {
            return Scaffold(
              appBar: AppBar(title: const Text('الدرس')),
              body: AppErrorView(
                message: state.message,
                onRetry: () => _cubit.load(widget.lessonId),
              ),
            );
          }
          final lesson = (state as ResourceLoaded<LessonDetailEntity>).data;
          return _LessonContent(
            lesson: lesson,
            resumeSeconds: widget.resumeSeconds,
          );
        },
      ),
    );
  }
}

class _LessonContent extends StatefulWidget {
  final LessonDetailEntity lesson;
  final int? resumeSeconds;
  const _LessonContent({required this.lesson, this.resumeSeconds});

  @override
  State<_LessonContent> createState() => _LessonContentState();
}

class _LessonContentState extends State<_LessonContent>
    with SingleTickerProviderStateMixin {
  YoutubePlayerController? _youtubeController;
  TabController? _tabController;
  Timer? _progressTimer;
  late final LessonDetailCubit _progressCubit;
  bool _completionSent = false;

  /// Fullscreen is driven entirely by this flag rather than
  /// `YoutubePlayerBuilder`'s automatic device-orientation detection —
  /// that package mechanism kept snapping back to portrait right after
  /// expanding, because its own metrics listener and our system-UI calls
  /// ended up racing each other. A single explicit toggle button is far
  /// more predictable: we control orientation and layout directly and
  /// nothing else is watching for changes to second-guess it.
  bool _isFullScreen = false;

  /// PDF-only lessons have no natural "finished" event the way a video
  /// does, so completion is reported manually via this button instead.
  bool _pdfCompleting = false;

  Future<void> _completePdfLesson() async {
    setState(() => _pdfCompleting = true);
    await _progressCubit.markCompleted(widget.lesson.id);
    if (!mounted) return;
    setState(() {
      _pdfCompleting = false;
      _completionSent = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم إكمال الدرس 🎉'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _progressCubit = context.read<LessonDetailCubit>();
    final lesson = widget.lesson;
    if (lesson.hasVideo) {
      final videoId = YoutubePlayer.convertUrlToId(lesson.videoUrl!);
      if (videoId != null) {
        _youtubeController = YoutubePlayerController(
          initialVideoId: videoId,
          flags: YoutubePlayerFlags(
            autoPlay: true,
            mute: false,
            startAt: widget.resumeSeconds ?? 0,
          ),
        )..addListener(_onPlayerStateChange);
        _startProgressTimer();
      }
    }
    if (lesson.hasVideo && lesson.hasFile) {
      _tabController = TabController(length: 2, vsync: this);
    }
  }

  /// Pings the server every 30 seconds while the video is actually
  /// playing, so the watch position survives even if the student never
  /// finishes the lesson or closes the app mid-video.
  void _startProgressTimer() {
    _progressTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      final controller = _youtubeController;
      if (controller != null && controller.value.isPlaying) {
        _progressCubit.savePosition(
          widget.lesson.id,
          controller.value.position.inSeconds,
        );
      }
    });
  }

  void _onPlayerStateChange() {
    final controller = _youtubeController;
    if (controller == null || _completionSent) return;
    final state = controller.value.playerState;
    final duration = controller.metadata.duration;
    // `youtube_player_flutter` doesn't reliably report `PlayerState.ended`
    // on every device — some videos settle into `paused` on the final
    // frame instead. Treat "paused right at the end" as finished too, so
    // completion isn't missed just because that event never fires.
    final nearEnd =
        duration > Duration.zero &&
        controller.value.position >= duration - const Duration(seconds: 2);
    final finished =
        state == PlayerState.ended || (state == PlayerState.paused && nearEnd);
    if (!finished) return;

    _completionSent = true;
    final seconds = duration > Duration.zero
        ? duration.inSeconds
        : controller.value.position.inSeconds;
    _progressCubit.markCompleted(widget.lesson.id, seconds).then((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إكمال الدرس 🎉'),
          backgroundColor: AppColors.success,
        ),
      );
    });
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    final controller = _youtubeController;
    if (controller != null) {
      controller.removeListener(_onPlayerStateChange);
      // Save the last known position on the way out — otherwise closing
      // the screen mid-video (before the next 30s tick) loses that
      // watch time entirely.
      if (!_completionSent) {
        final seconds = controller.value.position.inSeconds;
        if (seconds > 5) {
          _progressCubit.savePosition(widget.lesson.id, seconds);
        }
      }
    }
    _tabController?.dispose();
    // Safety net: never leave the rest of the app stuck sideways if this
    // screen is disposed while still in fullscreen.
    if (_isFullScreen) _setOrientationAndChrome(fullScreen: false);
    controller?.dispose();
    super.dispose();
  }

  void _setOrientationAndChrome({required bool fullScreen}) {
    if (fullScreen) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  void _toggleFullScreen() {
    final next = !_isFullScreen;
    setState(() => _isFullScreen = next);
    _setOrientationAndChrome(fullScreen: next);
  }

  List<Widget> _controls() => [
    const SizedBox(width: 14),
    const CurrentPosition(),
    const SizedBox(width: 8),
    const ProgressBar(isExpanded: true),
    const RemainingDuration(),
    const PlaybackSpeedButton(),
    IconButton(
      padding: EdgeInsets.zero,
      icon: Icon(
        _isFullScreen
            ? Icons.fullscreen_exit_rounded
            : Icons.fullscreen_rounded,
        color: Colors.white,
      ),
      onPressed: _toggleFullScreen,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final lesson = widget.lesson;
    final controller = _youtubeController;

    if (controller == null) {
      // No playable video (pdf-only lesson, or an unrecognized video URL).
      return Scaffold(
        appBar: AppBar(
          title: Text(
            lesson.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        body: lesson.hasFile
            ? Column(
                children: [
                  Expanded(child: PdfViewerBody(url: lesson.fileUrl!)),
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: ElevatedButton.icon(
                        onPressed: _pdfCompleting || _completionSent
                            ? null
                            : _completePdfLesson,
                        icon: _pdfCompleting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(
                                _completionSent
                                    ? Icons.check_circle_rounded
                                    : Icons.check_rounded,
                              ),
                        label: Text(
                          _completionSent
                              ? 'تم إكمال الدرس'
                              : 'تم الانتهاء من الدرس',
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : const AppErrorView(message: 'لا يوجد محتوى متاح لهذا الدرس بعد'),
      );
    }

    final player = YoutubePlayer(
      controller: controller,
      showVideoProgressIndicator: true,
      bottomActions: _controls(),
    );

    return PopScope(
      canPop: !_isFullScreen,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        // Back button while fullscreen exits fullscreen first, matching
        // the native YouTube app, instead of leaving the lesson outright.
        _toggleFullScreen();
      },
      child: _isFullScreen
          ? Scaffold(
              backgroundColor: Colors.black,
              body: SafeArea(child: Center(child: player)),
            )
          : Scaffold(
              appBar: AppBar(
                title: Text(
                  lesson.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              body: !lesson.hasFile
                  ? player
                  : Column(
                      children: [
                        TabBar(
                          controller: _tabController,
                          labelColor: AppColors.primary,
                          unselectedLabelColor: AppColors.textMuted,
                          indicatorColor: AppColors.primary,
                          tabs: const [
                            Tab(
                              icon: Icon(Icons.play_circle_outline_rounded),
                              text: 'الفيديو',
                            ),
                            Tab(
                              icon: Icon(Icons.picture_as_pdf_rounded),
                              text: 'الملف',
                            ),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              player,
                              PdfViewerBody(url: lesson.fileUrl!),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
    );
  }
}
