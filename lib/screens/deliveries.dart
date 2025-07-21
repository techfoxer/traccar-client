import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:traccar_client/l10n/app_localizations.dart';
import 'package:traccar_client/screens/widgets/sign_capture.dart';

class DeliveriesScreen extends StatefulWidget {
  const DeliveriesScreen({super.key});

  @override
  State<DeliveriesScreen> createState() => _DeliveriesScreenState();
}

class _DeliveriesScreenState extends State<DeliveriesScreen> {
  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(localization.deliveries)),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('${localization.deliveries} #${index + 1}'),
                  subtitle: Text('In Process'),
                  trailing: Wrap(
                    children: [
                      IconButton.filled(
                        color: Colors.white,
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => SignatureCapture(isFailed: true),
                            ),
                          );
                        },
                        icon: Icon(CupertinoIcons.clear),
                      ),
                      IconButton.filled(
                        onPressed: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SignatureCapture(),
                            ),
                          );
                        },
                        icon: Icon(
                          CupertinoIcons.check_mark,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
