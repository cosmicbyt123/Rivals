import 'package:flutter/material.dart';

import '../profile/Profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {  
  int _selectedTab = 0;

  static const gold = Color(0xFFFFC83D);      // Gold color used in the UI
  static const background = Color(0xFF101010);    // Background color for the home page
  static const surface = Color(0xFF191919);     // Surface color for cards and containers
  static const muted = Color(0xFFB9B3A8);     // Muted color for less prominent text and icons

  @override
  Widget build(BuildContext context) {      // Build the home page UI
    return Scaffold(
      backgroundColor: background,      
      bottomNavigationBar: _BottomBar(
        selectedIndex: _selectedTab,
        onSelected: (value) {
          setState(() => _selectedTab = value);

          if (value == 4) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProfilePage()),
            );
          }
        },
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 28, 18, 18),   // Padding for the content inside the ListView
          children: const [
            _Header(),
            SizedBox(height: 38),_StreakCard(),   //Space between the streak card and the next section
            
            SizedBox(height: 16),_TodayPlan(),    //Space between the today's plan and the next section
            
            SizedBox(height: 28),_StatsRow(),     //Space between the stats row and the next section
            
            SizedBox(height: 30),_ChallengeCard(),  //Space between the challenge card and the next section
            
            SizedBox(height: 32),_FriendsSection(),   //Space between the friends section and the next section
            
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {   // Header section of the home page
  const _Header();

  @override
  Widget build(BuildContext context) => Row(    
        crossAxisAlignment: CrossAxisAlignment.center,   
        children: [
          const _Photo(url: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=120&q=80', size: 50),   // User profile photo with a circular shape
          const SizedBox(width: 10),        // Space between the photo and the text
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Good Morning, Wasim', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),    // Greeting text
                SizedBox(height: 3),
                Text('Ready to beat yesterday?', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),   // Subtext below the greeting
              ],
            ),
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none, color: _HomePageState.muted, size: 25)),
        ],
      );
}

class _StreakCard extends StatelessWidget {     // Streak card section of the home page
  const _StreakCard();

  @override
  Widget build(BuildContext context) => Container(
        height: 180,
        padding: const EdgeInsets.fromLTRB(24, 25, 20, 22),   // Padding for the content inside the streak card
        decoration: BoxDecoration(color: _HomePageState.surface, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 8)]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [const Text('Daily Streak', style: TextStyle(color: _HomePageState.muted, fontSize: 15, fontWeight: FontWeight.w700)), const Spacer(), Container(padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 8), decoration: BoxDecoration(color: const Color(0xFF292929), borderRadius: BorderRadius.circular(18)), 
            child: const Text('12 Days', style: TextStyle(color: _HomePageState.gold, fontSize: 12, fontWeight: FontWeight.w800)))]),//
            const Spacer(),    // Space between the top row and the days of the week
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [
              _Day(label: 'M', state: _DayState.done), _Day(label: 'T', state: _DayState.done), _Day(label: 'W', state: _DayState.current), _Day(label: 'T', state: _DayState.empty), _Day(label: 'F', state: _DayState.empty), _Day(label: 'S', state: _DayState.empty), _Day(label: 'S', state: _DayState.empty),
            ]),
          ],
        ),
      );
}

enum _DayState { done, current, empty }     

class _Day extends StatelessWidget {
  const _Day({required this.label, required this.state});
  final String label;
  final _DayState state;

  @override
  Widget build(BuildContext context) {   // Build the UI for each day in the streak card
    final current = state == _DayState.current;
    final done = state == _DayState.done;
    return Column(children: [
      Text(label, style: const TextStyle(color: _HomePageState.muted, fontSize: 12, fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      Container(width: 34, height: 34, decoration: BoxDecoration(color: current ? _HomePageState.gold : done ? const Color(0xFF3C361D) : const Color(0xFF111111), shape: BoxShape.circle, boxShadow: current ? const [BoxShadow(color: Color(0x66FFC83D), blurRadius: 8)] : null), child: done ? const Icon(Icons.check, color: _HomePageState.gold, size: 17) : null),
    ]);
  }
}

class _TodayPlan extends StatelessWidget {    // Today's plan section of the home page
  const _TodayPlan();     

  @override
  Widget build(BuildContext context) => Container(     // Container for today's plan with padding and decoration
        padding: const EdgeInsets.fromLTRB(32, 28, 32, 32),
        decoration: BoxDecoration(color: _HomePageState.gold, borderRadius: BorderRadius.circular(10), boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 8)]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7), decoration: BoxDecoration(color: const Color(0x22FFFFFF), borderRadius: BorderRadius.circular(15)), child: const Text('⚒  TODAY\'S PLAN', style: TextStyle(color: Color(0xFF4B3900), fontSize: 11, fontWeight: FontWeight.w800))),
          const SizedBox(height: 20),
          const Text('PUSH DAY', style: TextStyle(color: Color(0xFF352700), fontSize: 23, fontWeight: FontWeight.w900)),
          const SizedBox(height: 7),
          const Text('Chest, Shoulders, Triceps', style: TextStyle(color: Color(0xFF5B4600), fontSize: 16)),
          const SizedBox(height: 30),
          Row(children: [Expanded(child: _PlanPill(icon: Icons.access_time, label: '55 min')), const SizedBox(width: 10), Expanded(child: _PlanPill(icon: Icons.format_list_bulleted, label: '7 Exercises'))]),
          const SizedBox(height: 30),
          SizedBox(width: double.infinity, height: 61, child: ElevatedButton.icon(onPressed: () {}, icon: const SizedBox.shrink(), label: const Text('START WORKOUT  →', style: TextStyle(color: _HomePageState.gold, fontSize: 17, fontWeight: FontWeight.w800)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF493500), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)), elevation: 0))),
        ]),
      );
}

class _PlanPill extends StatelessWidget {     // Plan pill widget used in the today's plan section
  const _PlanPill({required this.icon, required this.label});   
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(vertical: 11), decoration: BoxDecoration(color: const Color(0x1E8A6800), borderRadius: BorderRadius.circular(8)), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: const Color(0xFF493500), size: 21), const SizedBox(width: 7), Text(label, style: const TextStyle(color: Color(0xFF493500), fontSize: 14, fontWeight: FontWeight.w700))]));
}

class _StatsRow extends StatelessWidget {     // Stats row section of the home page
  const _StatsRow();

  @override
  Widget build(BuildContext context) => const Row(children: [   // Row containing three stats: KCAL, VOLUME (KG), and XP
        Expanded(child: _Stat(icon: Icons.local_fire_department_outlined, value: '620', label: 'KCAL')),
        SizedBox(width: 10),
        Expanded(child: _Stat(icon: Icons.shopping_bag_outlined, value: '8.4k', label: 'VOLUME\n(KG)')),
        SizedBox(width: 10),
        Expanded(child: _Stat(icon: Icons.star_border, value: '+240', label: 'XP', goldValue: true)),
      ]);
}

class _Stat extends StatelessWidget {     // Individual stat widget used in the stats row section
  const _Stat({required this.icon, required this.value, required this.label, this.goldValue = false});
  final IconData icon;
  final String value;
  final String label;
  final bool goldValue;

  @override
  Widget build(BuildContext context) => Container(height: 132, padding:   
  const EdgeInsets.only(top: 18), decoration: BoxDecoration(color: _HomePageState.surface, borderRadius: BorderRadius.circular(10)), child: Column(children: [Icon(icon, color: _HomePageState.gold, size: 22), 
  const SizedBox(height: 10), Text(value, style: TextStyle(color: goldValue ? _HomePageState.gold : Colors.white, fontSize: 30, fontWeight: FontWeight.w900)), 
  const SizedBox(height: 1), Text(label, textAlign: TextAlign.center, style: const TextStyle(color: _HomePageState.muted, fontSize: 10, fontWeight: FontWeight.w800, height: 1.1))]));     
}   

class _ChallengeCard extends StatelessWidget {      // Active challenge card section of the home page
  const _ChallengeCard();

  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.fromLTRB(23, 24, 23, 22), decoration: BoxDecoration(color: _HomePageState.surface, borderRadius: BorderRadius.circular(11)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [Icon(Icons.fitness_center, color: _HomePageState.muted, size: 15), SizedBox(width: 7), Text('Active Challenge', style: TextStyle(color: _HomePageState.muted, fontSize: 15, fontWeight: FontWeight.w800))]),
        const SizedBox(height: 23),
        const Row(crossAxisAlignment: CrossAxisAlignment.end, children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('100 Push-ups', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)), SizedBox(height: 3), Text('vs Rahul', style: TextStyle(color: _HomePageState.gold, fontSize: 13, fontWeight: FontWeight.w700))])), Text('72', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)), Padding(padding: EdgeInsets.only(bottom: 4), child: Text(' vs 64', style: TextStyle(color: _HomePageState.muted, fontSize: 17, fontWeight: FontWeight.w800)))]),
        const SizedBox(height: 17),
        ClipRRect(borderRadius: BorderRadius.circular(8), child: const LinearProgressIndicator(value: .72, minHeight: 13, backgroundColor: Color(0xFF302E29), valueColor: AlwaysStoppedAnimation(_HomePageState.gold))),
        const SizedBox(height: 8),
        const Align(alignment: Alignment.centerRight, child: Text('28 reps remaining', style: TextStyle(color: _HomePageState.muted, fontSize: 11))),
      ]));
}

class _FriendsSection extends StatelessWidget {   // Friends training now section of the home page
  const _FriendsSection();

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Padding(padding: EdgeInsets.only(left: 8), child: Text('Friends Training Now', style: TextStyle(color: _HomePageState.muted, fontSize: 15, fontWeight: FontWeight.w800))),
        const SizedBox(height: 17),
        Row(children: const [Expanded(child: _FriendCard(name: 'Rahul', workout: 'Leg Day', url: 'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=100&q=80')), SizedBox(width: 10), Expanded(child: _FriendCard(name: 'Arjun', workout: 'Cardio', url: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&q=80'))]),
      ]);
}

class _FriendCard extends StatelessWidget {     // Individual friend card widget used in the friends training now section
  const _FriendCard({required this.name, required this.workout, required this.url});
  final String name;
  final String workout;
  final String url;

  @override
  Widget build(BuildContext context) => Container(height: 76, padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: _HomePageState.surface, borderRadius: BorderRadius.circular(8)), child: Row(children: [Stack(children: [
        _Photo(url: url, size: 36),
        Positioned(right: 0, bottom: 0, child: Container(width: 9, height: 9, decoration: BoxDecoration(color: const Color(0xFF19D65A), shape: BoxShape.circle, border: Border.all(color: _HomePageState.surface, width: 1)))),
      ]), const SizedBox(width: 9), Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)), const SizedBox(height: 3), Text(workout, style: const TextStyle(color: _HomePageState.gold, fontSize: 12, fontWeight: FontWeight.w700))]))]));
}

class _Photo extends StatelessWidget {      // Circular photo widget used for user profile and friend cards
  const _Photo({required this.url, required this.size});
  final String url;
  final double size;

  @override
  Widget build(BuildContext context) => Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: _HomePageState.gold, width: size > 40 ? 1.5 : 0), color: const Color(0xFF383838)), child: ClipOval(child: Image.network(url, fit: BoxFit.cover, errorBuilder: (_, _, _) => Icon(Icons.person, color: _HomePageState.gold, size: size * .48))));
}

class _BottomBar extends StatelessWidget {    // Bottom navigation bar section of the home page
  const _BottomBar({required this.selectedIndex, required this.onSelected});
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) => Container(height: 82, padding: const EdgeInsets.symmetric(horizontal: 9), decoration: const BoxDecoration(color: Color(0xFF151515), border: Border(top: BorderSide(color: Color(0xFF242424)))), child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _NavItem(icon: Icons.home, label: 'Home', selected: selectedIndex == 0, onTap: () => onSelected(0)),
        _NavItem(icon: Icons.bar_chart, label: 'Ranks', selected: selectedIndex == 1, onTap: () => onSelected(1)),
        GestureDetector(onTap: () => onSelected(2), child: Container(width: 64, height: 64, decoration: const BoxDecoration(color: _HomePageState.gold, shape: BoxShape.circle), child: const Icon(Icons.bolt, color: Colors.black, size: 31))),
        _NavItem(icon: Icons.fitness_center, label: 'Workout', selected: selectedIndex == 3, onTap: () => onSelected(3)),
        _NavItem(icon: Icons.person_outline, label: 'Profile', selected: selectedIndex == 4, onTap: () => onSelected(4)),
      ]));
}

class _NavItem extends StatelessWidget {      // Individual navigation item widget used in the bottom navigation bar section
  const _NavItem({required this.icon, required this.label, required this.selected, required this.onTap});
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(onTap: onTap, child: SizedBox(width: 54, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: selected ? _HomePageState.gold : _HomePageState.muted, size: 21), const SizedBox(height: 5), Text(label, style: TextStyle(color: selected ? _HomePageState.gold : _HomePageState.muted, fontSize: 10, fontWeight: FontWeight.w800))])));
}
