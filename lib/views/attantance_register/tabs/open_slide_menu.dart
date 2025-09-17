import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class SideMenu {
  static void show(BuildContext context) {
    final width = MediaQuery.of(context).size.width * 0.6; // Half screen width

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Menu",
      pageBuilder: (_, __, ___) => Stack(
        children: [
          // Dark background overlay
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(color: Colors.black54),
          ),

          // Slide-in menu
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: width,
              height: double.infinity,
              child: Material(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Company Logo
                        Center(
                          child: Image.asset(
                            'assets/images/company_logo.jpeg', // Replace with your actual logo
                            width: 100,
                            height: 100,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // App Name / Description
                        const Center(
                          child: Text(
                            'Student Lesson & Attendance\nRegistration App',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        const Divider(),

                        // App Version
                        ListTile(
                          leading: const Icon(Icons.verified),
                          title: const Text('App Version'),
                          subtitle: const Text('1.0.0+1'),
                          onTap: () {},
                        ),

                        // Company Name
                        ListTile(
                          leading: CircleAvatar(
                            radius: 18,
                            backgroundImage: AssetImage('assets/images/company_logo.jpeg'),
                          ),
                          title: const Text('Company'),
                          subtitle: const Text('IT Artificer'),
                          onTap: () {},
                        ),

                        // Contact Number
                        ListTile(
                          leading: const Icon(Icons.phone),
                          title: const Text('Contact'),
                          subtitle: const Text('+92 333 9296314'),
                          onTap: () {},
                        ),

                        // Share App Button
                        ListTile(
                          leading: const Icon(Icons.share),
                          title: const Text('Share App'),
                          onTap: () {
                            Share.share(
                              'Check out the Mandrass App!\nStudent Lesson & Attendance Registration App\nCompany: IT Artificer\nContact: +92 333 9296314',
                              subject: 'Mandrass App',
                            );
                          },
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      transitionBuilder: (_, anim, __, child) {
        return SlideTransition(
          position: Tween(begin: const Offset(1, 0), end: Offset.zero).animate(anim),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 250),
    );
  }
}
