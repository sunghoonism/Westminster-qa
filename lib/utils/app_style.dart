import 'package:flutter/material.dart';

/// 앱 전반의 색상을 한곳에 모아둔다.
///
/// 타이틀(앱바)은 본문보다 진한 갈색으로 두어 경계를 분명히 하고,
/// 문답 목록은 표처럼 행마다 배경색을 번갈아 적용한다.
class AppStyle {
  /// 타이틀 영역(앱바) 배경.
  static const Color appBarColor = Color(0xFF5D4037);

  /// 본문 기본 배경. 목록의 짝수 행과 여백에 쓰인다.
  static const Color bodyColor = Color(0xFFFFFFFF);

  /// 번갈아 칠할 홀수 행 배경. 앱바와 같은 갈색 계열의 옅은 톤.
  static const Color bodyAltColor = Color(0xFFF3EADF);

  /// 질문은 답변보다 진한 갈색으로 강조한다.
  static const Color questionColor = Color(0xFF4E342E);

  /// 답변 본문 색.
  static const Color answerColor = Color(0xFF212121);

  /// 표처럼 보이도록 행 배경색을 번갈아 반환한다.
  static Color rowColor(int index) => index.isEven ? bodyColor : bodyAltColor;
}
