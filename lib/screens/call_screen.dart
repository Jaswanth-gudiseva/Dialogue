import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as rtc_local_view;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as rtc_remote_view;
import 'package:teams_app/app_id.dart';

import 'package:teams_app/screens/chat_screen.dart';

const String userLimit =
    'Currently, Dialogue supports only upto 6 users in a video '
    'call at once. To continue with the Video call, please make '
    'sure there are only 6 users at once.';

class CallScreen extends StatefulWidget {
  String meetCode = '';
  String username;
  String roomName;
  bool isInstant;
  CallScreen(
      {required this.meetCode,
      required this.username,
      required this.isInstant,
      required this.roomName});

  @override
  _CallScreenState createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  static final _users = <int>[];
  final _infoStrings = <String>[];
  bool muted = false;
  bool showVideo = true;
  late RtcEngine _engine;

  @override
  void dispose() {
    super.dispose();
    _users.clear();
    // destroy sdk
    _engine.leaveChannel();
    _engine.destroy();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initialize();
  }

  // Initializes the Agora RTC Engine and Event Handlers
  Future<void> initialize() async {
    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();
    // await _engine.enableWebSdkInteroperability(true);
    await _engine.joinChannel(null, widget.meetCode, null, 0);
  }

  //
  Future<void> _initAgoraRtcEngine() async {
    _engine = await RtcEngine.create(appId);
    await _engine.enableVideo();
  }

  void _addAgoraEventHandlers() {
    _engine.setEventHandler(
      RtcEngineEventHandler(
        error: (code) {
          setState(() {
            final info = 'onError: $code';
            _infoStrings.add(info);
          });
        },
        joinChannelSuccess: (channel, uid, elapsed) {
          setState(() {
            final info = 'onJoinChannel: $channel, uid: $uid';
            _infoStrings.add(info);
          });
        },
        leaveChannel: (stats) {
          setState(() {
            _infoStrings.add('onLeaveChannel');

            _users.clear();
          });
        },
        userJoined: (uid, elapsed) {
          setState(() {
            final info = 'userJoined: $uid';
            _infoStrings.add(info);
            _users.add(uid);
          });
        },
        userOffline: (uid, reason) {
          setState(() {
            final info = 'userOffline: $uid , reason: $reason';
            _infoStrings.add(info);
            _users.remove(uid);
          });
        },
        firstRemoteVideoFrame: (uid, width, height, elapsed) {
          setState(() {
            final info = 'firstRemoteVideoFrame: $uid';
            _infoStrings.add(info);
          });
        },
      ),
    );
  }

  Widget _toolbar() {
    return Container(
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(
        vertical: 48,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RawMaterialButton(
            onPressed: _onToggleVideo,
            constraints: const BoxConstraints(maxHeight: 40, maxWidth: 40),
            child: Icon(
              showVideo ? Icons.videocam : Icons.videocam_off,
              color: showVideo ? Theme.of(context).primaryColor : Colors.white,
              size: 20.0,
            ),
            shape: const CircleBorder(),
            elevation: 2.0,
            fillColor:
                showVideo ? Colors.white : Theme.of(context).primaryColor,
            padding: const EdgeInsets.all(10.0),
          ),
          RawMaterialButton(
            onPressed: _onToggleMute,
            child: Icon(
              muted ? Icons.mic_off : Icons.mic,
              color: muted ? Colors.white : Theme.of(context).primaryColor,
              size: 20.0,
            ),
            shape: const CircleBorder(),
            elevation: 2.0,
            fillColor: muted ? Theme.of(context).primaryColor : Colors.white,
            padding: const EdgeInsets.all(10.0),
          ),
          RawMaterialButton(
            onPressed: () => _onCallEnd(context),
            constraints: const BoxConstraints(maxHeight: 60, maxWidth: 60),
            child: const Icon(
              Icons.call_end,
              color: Colors.white,
              size: 30.0,
            ),
            shape: const CircleBorder(),
            elevation: 2.0,
            fillColor: Color(0xffd54c4c),
            padding: const EdgeInsets.all(10.0),
          ),
          RawMaterialButton(
            onPressed: _onSwitchCamera,
            child: const Icon(
              Icons.switch_camera,
              color: Colors.white,
              size: 20.0,
            ),
            shape: const CircleBorder(),
            elevation: 2.0,
            fillColor: Theme.of(context).primaryColor,
            padding: const EdgeInsets.all(10.0),
          ),
          RawMaterialButton(
            constraints: const BoxConstraints(maxHeight: 40, maxWidth: 40),
            onPressed: () {
              print(widget.meetCode);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      fromRoom: false,
                      roomName: 'Room',
                      isInstant: widget.isInstant,
                      chatCode: widget.meetCode,
                      username: widget.username,
                    ),
                  ));
            },
            child: const Icon(
              Icons.chat,
              color: Colors.white,
              size: 20.0,
            ),
            shape: const CircleBorder(),
            elevation: 2.0,
            fillColor: Theme.of(context).primaryColor,
            padding: const EdgeInsets.all(10.0),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          widget.isInstant ? 'Instant Meeting' : widget.roomName,
          style: TextStyle(fontFamily: 'Mons'),
        ),
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: Stack(
          children: <Widget>[
            _viewRows(),
            _toolbar(),
          ],
        ),
      ),
    );
  }

  List<Widget> _getRenderViews() {
    final List<StatefulWidget> list = [];
    list.add(rtc_local_view.SurfaceView());
    for (var uid in _users) {
      list.add(rtc_remote_view.SurfaceView(uid: uid));
    }
    return list;
  }

  /// Video view wrapper
  Widget _videoView(view) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(40)),
        child: view,
      ),
    );
  }

  /// Video view row wrapper
  Widget _expandedVideoRow(List<Widget> views) {
    final wrappedViews = views.map<Widget>(_videoView).toList();
    return Expanded(
      child: Container(
        child: Row(
          children: wrappedViews,
        ),
      ),
    );
  }

  /// Video layout wrapper
  Widget _viewRows() {
    final views = _getRenderViews();
    switch (views.length) {
      case 1:
        return Column(
          children: <Widget>[_videoView(views[0])],
        );
      case 2:
        return Column(
          children: <Widget>[
            _expandedVideoRow([views[0]]),
            _expandedVideoRow([views[1]])
          ],
        );
      case 3:
        return Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 3))
          ],
        );
      case 4:
        return Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 4))
          ],
        );
      case 5:
        return Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 4)),
            _expandedVideoRow(views.sublist(4, 5)),
          ],
        );
      case 6:
        return Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 4)),
            _expandedVideoRow(views.sublist(4, 6)),
          ],
        );
      default:
        return Container(
          color: Theme.of(context).primaryColor,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                userLimit,
                style: TextStyle(
                    color: Color(0xfff0e3e3),
                    fontFamily: 'Mons',
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
        );
    }
  }

  void _onCallEnd(BuildContext context) {
    Navigator.pop(context);
    if (_users.isEmpty) {
      FirebaseFirestore.instance
          .collection('instantMeeting')
          .doc(widget.meetCode)
          .collection(widget.meetCode)
          .get()
          .then(
        (snapshot) {
          for (DocumentSnapshot doc in snapshot.docs) {
            doc.reference.delete();
          }
        },
      );

      FirebaseFirestore.instance
          .collection('instantMeeting')
          .doc(widget.meetCode)
          .delete();
    }
  }

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    _engine.muteLocalAudioStream(muted);
  }

  void _onToggleVideo() {
    setState(() {
      showVideo = !showVideo;
    });
    _engine.enableLocalVideo(showVideo);
    // _engine.muteLocalVideoStream(showVideo);
  }

  void _onSwitchCamera() {
    _engine.switchCamera();
  }
}
