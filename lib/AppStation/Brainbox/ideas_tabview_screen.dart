import 'package:flutter/material.dart';
import 'package:resus_test/AppStation/Brainbox/Tab%20Screens/pending_ideas.dart';

import '../../../Utility/utils/constants.dart';
import 'Tab Screens/approved_ideas.dart';
import 'Tab Screens/my_ideas.dart';
import 'brainbox_onboard_screen.dart';

class IdeasTabviewScreen extends StatefulWidget {
  int selectedPage;

  IdeasTabviewScreen(this.selectedPage, {super.key});

  @override
  State<IdeasTabviewScreen> createState() => _IdeasTabviewScreenState();
}

class _IdeasTabviewScreenState extends State<IdeasTabviewScreen> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) {
          return;
        }
        _showBackDialog().then((value) {
          if (value != null && value) {
            Navigator.of(context).pop();
          }
        });
      },
      child: Material(
        child: DefaultTabController(
          initialIndex: widget.selectedPage,
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              leading: InkWell(
                  onTap: () async {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => BrainboxOnboardScreen(
                                googleSignInAccount: null,
                                userId: "",
                                emailId: "",
                                initialSelectedIndex: null)));
                  },
                  child: const Icon(Icons.arrow_back_ios)),
              key: const ValueKey('tabviewContainer'),
              backgroundColor: kReSustainabilityRed,
              title: const Text(
                "Ideas Report",
                style: TextStyle(
                    fontFamily: "ARIAL",
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white),
              ),
              centerTitle: true,
              elevation: 0,
              bottom: const TabBar(
                tabs: [
                  Tab(
                    child: Text(
                      "My Ideas",
                      style: TextStyle(
                          fontFamily: "ARIAL",
                          fontSize: 13,
                          color: Colors.white),
                    ),
                  ),
                  Tab(
                    child: Text(
                      "Pending Ideas",
                      style: TextStyle(
                          fontFamily: "ARIAL",
                          fontSize: 13,
                          color: Colors.white),
                    ),
                  ),
                  Tab(
                    child: Text(
                      "Approved Ideas",
                      style: TextStyle(
                          fontFamily: "ARIAL",
                          fontSize: 13,
                          color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            body: const TabBarView(
              children: [MyIdeas(), PendingIdeas(), ApprovedIdeas()],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _showBackDialog() {
    return showDialog<bool>(
      context: context,
      useRootNavigator: false,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            title: const Text('Please confirm',
                style: TextStyle(
                  color: kReSustainabilityRed,
                  fontFamily: "ARIAL",
                )),
            content: const Text('Do you want go back to BrainBox Home!',
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: "ARIAL",
                )),
            actions: <Widget>[
              TextButton(
                child: const Text('No',
                    style: TextStyle(
                      color: kReSustainabilityRed,
                      fontFamily: "ARIAL",
                    )),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                onPressed: () =>
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => BrainboxOnboardScreen(googleSignInAccount: null, userId: "", emailId: "", initialSelectedIndex: 0),)),
                child: const Text(
                  'Yes',
                  style: TextStyle(
                    color: kReSustainabilityRed,
                    fontFamily: "ARIAL",
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
