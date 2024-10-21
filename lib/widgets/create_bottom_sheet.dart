import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../widgets/text_form_field.dart';
import '../screens/chat/qr_scanner.dart';
import 'custom_elevated_button.dart';

class CreateChatBottomSheet extends StatefulWidget {
  final Function(String email) onCreateRoom;
  final String txtOfButton;

  const CreateChatBottomSheet({
    super.key,
    required this.onCreateRoom,
    required this.txtOfButton,
  });

  @override
  State<CreateChatBottomSheet> createState() => _CreateChatBottomSheetState();
}

class _CreateChatBottomSheetState extends State<CreateChatBottomSheet> {
  TextEditingController emailCon = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
                        builder: (context) => QrCodeScannerScreen()),
                  );
                },
                icon: const Icon(Iconsax.scan_barcode),
              )
            ],
          ),
          CustomTextFormField(
            controller: emailCon,
            prefixIcon: Iconsax.direct,
            label: "Email",
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(
            height: 16,
          ),
          CustomElevatedButton(
            text: widget.txtOfButton,
            onPressed: () {
              if (emailCon.text.isNotEmpty) {
                widget.onCreateRoom(emailCon.text);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please enter an email")),
                );
              }
            },
          )
        ],
      ),
    );
  }
}

/*
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            ),
            onPressed: () {
              if (emailCon.text.isNotEmpty) {
                widget.onCreateRoom(emailCon.text);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please enter an email")),
                );
              }
            },
            child: Center(
              child: Text(widget.txtOfButton),
            ),
          )
 */
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:iconsax/iconsax.dart';
//
// import '../../firebase/fire_database.dart';
//
// import '../../widgets/text_form_field.dart';
//
// class CreateChatBottomSheet extends StatefulWidget {
//   final TextEditingController emailController;
//
//   const CreateChatBottomSheet({Key? key, required this.emailController,
//
//   })
//       : super(key: key);
//
//   @override
//   _CreateChatBottomSheetState createState() => _CreateChatBottomSheetState();
// }
//
// class _CreateChatBottomSheetState extends State<CreateChatBottomSheet> {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Row(
//             children: [
//               Text(
//                 "Enter your friend's email",
//                 style: Theme.of(context).textTheme.bodyLarge,
//               ),
//               const Spacer(),
//               IconButton.filled(
//                 onPressed: () {},
//                 icon: const Icon(Iconsax.scan_barcode),
//               ),
//             ],
//           ),
//           CustomTextFormField(
//             controller: widget.emailController,
//             prefixIcon: Iconsax.direct,
//             label: "Email",
//             keyboardType: TextInputType.emailAddress,
//           ),
//           const SizedBox(
//             height: 16,
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               padding: const EdgeInsets.all(16),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               backgroundColor: Theme.of(context).colorScheme.primaryContainer,
//             ),
//             onPressed: () async {
//               QuerySnapshot friendEmail = await FirebaseFirestore.instance
//                   .collection('users')
//                   .where('email', isEqualTo: widget.emailController.text)
//                   .get();
//
//               if (widget.emailController.text.isNotEmpty) {
//                 if (friendEmail.docs.isEmpty) {
//                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//                       content: Text("This email does not exist")));
//                 } else {
//                   await FireData().createRoom(widget.emailController.text).then(
//                     (value) {
//                       Navigator.pop(context);
//                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//                           content: Text("The room has been created.")));
//                       widget.emailController.clear();
//                     },
//                   ).onError((error, stackTrace) {
//                     print("Error while creating room: $error");
//                   });
//                 }
//               }
//             },
//             child: const Center(
//               child: Text("Create Chat"),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
