import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DonationDialog {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('아직 구현되지 않은 기능입니다.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
        );
      }
    );
  }
}

// class DonationDialog {
//   static void show(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('후원 안내'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text('아래 방법 중 편하신 방법으로 후원하실 수 있습니다.'),
//               const SizedBox(height: 16),
//               _DonationItem(
//                 label: '카카오페이',
//                 value: '010-1234-5678',
//               ),
//               _DonationItem(
//                 label: '토스',
//                 value: '010-1234-5678',
//               ),
//               _DonationItem(
//                 label: '계좌번호',
//                 value: '국민은행 123456-78-901234',
//               ),
//               const SizedBox(height: 16),
//               Center(
//                 child: ElevatedButton.icon(
//                   icon: const Icon(Icons.payment),
//                   label: const Text('구글 플레이 인앱결제'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green,
//                     foregroundColor: Colors.white,
//                   ),
//                   onPressed: () {
//                     _showInAppPurchaseInfo(context);
//                   },
//                 ),
//               ),
//               const SizedBox(height: 12),
//               const Text(
//                 '후원해주셔서 감사합니다!\n문의: example@email.com',
//                 style: TextStyle(fontSize: 13, color: Colors.grey),
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text('닫기'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   static void _showInAppPurchaseInfo(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('구글 인앱결제'),
//         content: const Text('구글 플레이 인앱결제는 추후 지원될 예정입니다.'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('확인'),
//           ),
//         ],
//       ),
//     );
//   }
// }

class _DonationItem extends StatelessWidget {
  final String label;
  final String value;
  const _DonationItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 15)),
          ),
          IconButton(
            icon: const Icon(Icons.copy, size: 18),
            tooltip: '복사',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$label 복사됨')),
              );
            },
          ),
        ],
      ),
    );
  }
} 