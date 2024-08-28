import 'package:flutter/material.dart';
import 'package:resus_test/AppStation/Protect/Incident_report/pending_actions.dart';
import '../../../Utility/utils/constants.dart';
import '../ProtectOnboardScreen.dart';
import 'action_taken.dart';
import 'my_ir.dart';

class IncidentTabviewScreen extends StatefulWidget {
  int selectedPage;

  IncidentTabviewScreen(this.selectedPage, {super.key});

  @override
  State<IncidentTabviewScreen> createState() => _IncidentTabviewScreenState();
}

class _IncidentTabviewScreenState extends State<IncidentTabviewScreen> {
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
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProtectOnboard(),
                    ),
                  );
                },
              ),
              key: const ValueKey('tabviewContainer'),
              backgroundColor: kReSustainabilityRed,
              title: const Text(
                "Incident Report",
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
                      "My IR",
                      style: TextStyle(
                          fontFamily: "ARIAL",
                          fontSize: 13,
                          color: Colors.white),
                    ),
                  ),
                  Tab(
                    child: Text(
                      "Pending Actions",
                      style: TextStyle(
                          fontFamily: "ARIAL",
                          fontSize: 13,
                          color: Colors.white),
                    ),
                  ),
                  Tab(
                    child: Text(
                      "Action Taken",
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
              children: [MyIR(), PendingActions(), ActionTaken()],
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
            content: const Text('Do you want go back to Protect Home!',
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
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ProtectOnboard(),)),
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