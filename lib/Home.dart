import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:rxdart/rxdart.dart';
import 'Control.dart';

class AudioPlayerScreen extends StatefulWidget {
  const AudioPlayerScreen({super.key});

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  late AudioPlayer _audioPlayer;

  final _playlist = ConcatenatingAudioSource(
    children: [
      AudioSource.uri(
        Uri.parse('asset:///assets/audio/nature.mp3'),
        tag: MediaItem(
            id: '0',
            title: 'Nature Sounds',
            artist: 'Public Domain',
            artUri: Uri.parse('https://unsplash.com/photos/HBx7z6xHKrM'),),
      ),
    ],
  );
  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
        _audioPlayer.positionStream,
        _audioPlayer.bufferedPositionStream,
        _audioPlayer.durationStream,
        (position, bufferPosition, duration) =>
            PositionData(position, bufferPosition, duration ?? Duration.zero),
      );
  @override
  void initState() {
    super.initState();
    // _audioPlayer = AudioPlayer()..setAsset('assets/audio/nature.mp3');
    // _audioPlayer = AudioPlayer()..setUrl('https://soundcloud.com/lakeyinspired/in-my-clouds?utm_source=clipboard&utm_medium=text&utm_campaign=social_sharing');
    // _audioPlayer.positionStream;
    // _audioPlayer.bufferedPositionStream;
    // _audioPlayer.durationStream;
    _audioPlayer = AudioPlayer();
    _init();
  }

  Future<void> _init() async {
    await _audioPlayer.setLoopMode(LoopMode.all);
    await _audioPlayer.setAudioSource(_playlist);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_horiz),
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xff144771), Color(0xff071A2C)]),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StreamBuilder<SequenceState>(builder: (context, snapshot) {
              stream:
              _audioPlayer.sequenceStateStream;
              final state = snapshot.data;
              if (state?.sequence.isEmpty ?? true) {
                return const SizedBox();
              }
              final metadata = state!.currentSource!.tag as MediaItem;
              return MediaMetadata(
                  imageUrl: metadata.artUri.toString(),
                  title: metadata.title,
                  artist: metadata.artist ?? '');
            }),
            const SizedBox(
              height: 20,
            ),
            StreamBuilder(
              builder: (context, snapshot) {
                final positionData = snapshot.data;
                return ProgressBar(
                  barHeight: 8,
                  baseBarColor: Colors.grey[600],
                  bufferedBarColor: Colors.grey,
                  timeLabelTextStyle: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700),
                  progress: positionData?.position ?? Duration.zero,
                  total: positionData?.duration ?? Duration.zero,
                  buffered: positionData?.duration ?? Duration.zero,
                  onSeek: _audioPlayer.seek,
                );
              },
              stream: _positionDataStream,
            ),
            Controls(audioPlayer: _audioPlayer),
          ],
        ),
      ),
    );
  }
}

class PositionData {
  const PositionData(this.position, this.bufferPosition, this.duration);
  final Duration position;
  final Duration bufferPosition;
  final Duration duration;
}

class MediaMetadata extends StatelessWidget {
  const MediaMetadata(
      {super.key,
      required this.imageUrl,
      required this.title,
      required this.artist});
  final String imageUrl;
  final String title;
  final String artist;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                offset: Offset(2, 4),
                blurRadius: 4,
              ),
            ],
            borderRadius: BorderRadius.circular(10),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              height: 300,
              width: 300,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(
          height: 8,
        ),
        Text(
          artist,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
