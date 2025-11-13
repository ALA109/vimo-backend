import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class VideoController extends GetxController {
  VideoController({required this.videoUrl});

  late final VideoPlayerController videoPlayerController;
  final String videoUrl;

  final isPlaying = false.obs;
  final isMuted = false.obs;
  final isInitialized = false.obs;
  final currentPosition = Duration.zero.obs;
  final totalDuration = Duration.zero.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    videoPlayerController =
        VideoPlayerController.networkUrl(Uri.parse(videoUrl));

    await videoPlayerController.setLooping(true);
    await videoPlayerController.initialize();

    isInitialized.value = true;
    totalDuration.value = videoPlayerController.value.duration;
    await videoPlayerController.play();
    isPlaying.value = true;
    update();

    videoPlayerController.addListener(() {
      currentPosition.value = videoPlayerController.value.position;
      isPlaying.value = videoPlayerController.value.isPlaying;
    });
  }

  void togglePlayPause() {
    if (isPlaying.value) {
      videoPlayerController.pause();
    } else {
      videoPlayerController.play();
    }
    isPlaying.value = videoPlayerController.value.isPlaying;
  }

  void toggleMute() {
    if (isMuted.value) {
      videoPlayerController.setVolume(1.0);
    } else {
      videoPlayerController.setVolume(0.0);
    }
    isMuted.value = !isMuted.value;
  }

  void seekTo(Duration position) {
    videoPlayerController.seekTo(position);
  }

  @override
  void onClose() {
    videoPlayerController.dispose();
    super.onClose();
  }
}
