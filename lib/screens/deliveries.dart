import 'package:flutter/material.dart';
import 'package:traccar_client/l10n/app_localizations.dart';
import 'package:traccar_client/screens/widgets/sign_capture.dart';
import 'package:traccar_client/widgets/basic_button.dart';

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
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.deliveries)),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('${localization.deliveries} #${index + 1}'),
                  subtitle: Text('In Process'),
                  trailing: BasicButton(
                    text: localization.deliver,
                    onPressed: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SignatureCapture(),
                        ),
                      );
                    },
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
