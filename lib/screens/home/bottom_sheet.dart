import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../widgets/custom_elevated_button.dart';
import '../../widgets/text_form_field.dart';
import '../chat/qr_scanner.dart';

class CreateBottomSheet extends StatefulWidget {
  final VoidCallback onPressed;
  final String txtOfButton;
  final TextEditingController controller;

  const CreateBottomSheet({
    super.key,
    required this.onPressed,
    required this.txtOfButton,
    required this.controller,
  });

  @override
  State<CreateBottomSheet> createState() => _CreateChatBottomSheetState();
}

class _CreateChatBottomSheetState extends State<CreateBottomSheet> {
  TextEditingController emailCon = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        border: BorderDirectional(
          top: BorderSide(color: Theme.of(context).colorScheme.primaryContainer,width: 3),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                "Enter your friend's email",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const Spacer(),
              IconButton.filled(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const QrCodeScannerScreen()),
                  );
                },
                icon: const Icon(Iconsax.scan_barcode),
              )
            ],
          ),
          CustomTextFormField(
            autofocus: true,
            controller: widget.controller,
            prefixIcon: Iconsax.direct,
            label: "Email",
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(
            height: 16,
          ),
          CustomElevatedButton(
            text: widget.txtOfButton,
            onPressed: widget.onPressed,
          )
        ],
      ),
    );
  }
}
