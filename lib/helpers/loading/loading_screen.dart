import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_course_2/helpers/loading/loading_screen_controler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoadingScreen {
  factory LoadingScreen() => _shared;
  static final LoadingScreen _shared = LoadingScreen._sharedInstance();
  LoadingScreen._sharedInstance();

  LoadingScreenController? controller;

  void show({
    required BuildContext context, 
    required String text,
  }){
    if (controller?.update(text) ?? false) {
      return;
    } else {
      controller = showOverLay(
        context: context,
        text: text,
      );
    }
  }

  void hide() {
    controller?.close();
    controller = null;
  }

  LoadingScreenController showOverLay({
    required BuildContext context,
    required String text,
  }) {
    final text0 = StreamController<String>();
    text0.add(text);

    final state = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final overlay = OverlayEntry(
      builder: (context) {
        return Material(
          color: Colors.black.withValues(alpha: 150/255), // Fixed alpha value 0-1
          child: Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: size.width * 0.8,
                maxHeight: size.height * 0.8,
                minWidth: size.width * 0.5,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0.r),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.0.r),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 10.h),
                      const CircularProgressIndicator(),
                      SizedBox(height: 20.h),
                      StreamBuilder(
                        stream: text0.stream,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Text(
                              snapshot.data as String,
                              textAlign: TextAlign.center,
                            );
                          } else {
                            return Container();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    state.insert(overlay);

    return LoadingScreenController(
      () {
        text0.close();
        overlay.remove();
        return true;
      },
      (text) {
        text0.add(text);
        return true;
      },
    );
  }
}
