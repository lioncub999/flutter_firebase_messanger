import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../main.dart';

// ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
// ┃                             BottomNavigationBar 공통                             ┃
// ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
class BottomNavbar extends StatelessWidget {
  const BottomNavbar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        // tapState 로 현재 화면 확인
        currentIndex: context.watch<MainStore>().tapState,
        onTap: (i) {
          context.read<MainStore>().setTapState(i);
        },
        items: [
          // 토크 아이콘
          BottomNavigationBarItem(
            label: '토크',
            icon: SvgPicture.asset('assets/icons/talkIcon.svg'),
            activeIcon: SvgPicture.asset('assets/icons/talkIcon.svg'),
          ),
          // 내주변 아이콘
          BottomNavigationBarItem(
            label: '내주변',
            icon: SvgPicture.asset('assets/icons/locationIcon.svg'),
            activeIcon: SvgPicture.asset('assets/icons/locationIcon.svg'),

          ),
          // 채팅 아이콘
          BottomNavigationBarItem(
            label: '채팅',
            icon: SvgPicture.asset('assets/icons/chatIcon.svg'),
            activeIcon: SvgPicture.asset('assets/icons/chatIcon.svg'),
          ),
          // 더보기 아이콘
          BottomNavigationBarItem(
            label: '더보기',
            icon: SvgPicture.asset('assets/icons/moreIcon.svg'),
            activeIcon: SvgPicture.asset('assets/icons/moreIcon.svg'),
          )
        ]);
  }
}
