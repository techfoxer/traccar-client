import 'package:flutter/material.dart';

import '../../constants/resources.dart';
import '../../utils/responsive.dart';
import '../../utils/widget_utils.dart';
import 'login_form.dart';
import 'register_form.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Image.asset(
                    Resources.logoImg,
                    width: Responsive.width(context) * .5,
                  ),
                ),
                space(20),
                Text(
                  "Welcome to Traccar",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      TabBar(
                        controller: _tabController,
                        labelColor: Colors.deepPurple,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: Colors.deepPurple,
                        tabs: const [Tab(text: 'Login'), Tab(text: 'Register')],
                      ),
                      SizedBox(
                        height: 400,
                        child: TabBarView(
                          controller: _tabController,
                          children: const [LoginForm(), RegisterForm()],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
