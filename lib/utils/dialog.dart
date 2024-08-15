import 'package:flutter/material.dart';

Future<dynamic> showInfo(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('앱 정보'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('개발자 연락처',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text('sunghoonism2@gmail.com'),
            SizedBox(height: 10),
            Text('주의사항',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text('본 어플은 알려진 문서를 어플로 변환한 것 뿐이며, 어떠한 신학적 견해도 담고 있지 않음을 밝힙니다.'),
          ],
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
