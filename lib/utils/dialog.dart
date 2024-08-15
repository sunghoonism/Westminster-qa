import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<dynamic> showInfo(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('앱 정보'),
        content: RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.black),
            children: [
              const TextSpan(
                text: '개발자 연락처\n',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const TextSpan(text: 'sunghoonism2@gmail.com\n\n'),
              const TextSpan(
                text: '주의사항\n',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const TextSpan(
                  text:
                      '본 어플은 알려진 문서를 어플로 변환한 것 뿐이며, 어떠한 신학적 견해도 담고 있지 않음을 밝힙니다.\n\n'),
              const TextSpan(
                text: '코드 공개\n',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              TextSpan(
                text: 'https://github.com/sunghoonism/Westminster-qa',
                style: const TextStyle(color: Colors.blue),
                recognizer: TapGestureRecognizer()
                  ..onTap = () async {
                    await Clipboard.setData(const ClipboardData(
                        text: "https://github.com/sunghoonism/Westminster-qa"));
                  },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('닫기'),
          ),
        ],
      );
    },
  );
}

Future<dynamic> simpleDialogue(
    BuildContext context, String title, String content) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('닫기'),
          ),
        ],
      );
    },
  );
}
