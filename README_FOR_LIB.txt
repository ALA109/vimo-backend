Vimo lib/ scaffold
------------------
- Fill Supabase credentials in core/constants/app_constants.dart
- Add dependencies in pubspec.yaml:
  supabase_flutter, video_player, flutter_bloc or riverpod (optional), dio (optional)
- This scaffold uses simple MVC-ish separation with domain/data/presentation layers.

Notes:
- Real video playback and live streaming are TODOs.
- Realtime example is provided for likes table via RealtimeChannel.
