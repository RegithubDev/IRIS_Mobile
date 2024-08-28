import 'package:flutter/material.dart';

import '../../components/labeled_text_form_field.dart';
import '../../routes/routes.dart';

class InputWidget extends StatefulWidget {
  const InputWidget({super.key});

  @override
  _InputWidgetState createState() => _InputWidgetState();
}

class _InputWidgetState extends State<InputWidget> {
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('inputWidgetContainer1'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        LabeledTextFormField(
          title: 'email :',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          hintText: 'Enter Your Email',
        ),
        Row(
          children: [
            Expanded(
              child: Container(),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed(Routes.forgotPassword);
              },
              child: Text(
                'forgot_yout_password',
                style: Theme.of(context)
                    .textTheme
                    .labelLarge!
                    .copyWith(fontSize: 12, color: Colors.black),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
