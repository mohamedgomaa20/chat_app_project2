import 'package:flutter/material.dart';

import 'package:iconsax/iconsax.dart';

import '../utils/colors.dart';

class CustomTextFormField extends StatefulWidget {
  final String label;
  final IconData? prefixIcon;
  final TextEditingController controller;
  final bool isPassword;
  final TextInputType? keyboardType;

  const CustomTextFormField({
    super.key,
    required this.label,
    required this.prefixIcon,
    required this.controller,
    this.isPassword = false,
    this.keyboardType,
  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  bool obscure = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: TextFormField(
        controller: widget.controller,
        keyboardType: widget.keyboardType,
        obscureText: widget.isPassword ? obscure : false,
        validator: (value) {
          if (value!.isEmpty) {
            return "Field Required";
          } else {
            return null;
          }
        },
        decoration: InputDecoration(
          prefixIcon: Icon(widget.prefixIcon),
          labelText: widget.label,
          suffixIcon: widget.isPassword
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      obscure = !obscure;
                    });
                  },
                  icon: Icon(
                    obscure ? Iconsax.eye : Iconsax.eye_slash,
                  ),
                )
              : const SizedBox(),
          // contentPadding: const EdgeInsets.all(16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: kPrimaryColor, width: 2)),
        ),
      ),
    );
  }
}

/*
// import 'package:flutter/material.dart';
// import 'package:iconsax/iconsax.dart';
//
// import '../utils/colors.dart';
//
// class CustomField extends StatefulWidget {
//   final IconData icon;
//   final String label;
//   final TextEditingController controller;
//   final bool isPass;
//
//   const CustomField({
//     super.key,
//     required this.icon,
//     required this.label,
//     required this.controller,
//     this.isPass = false,
//   });
//
//   @override
//   State<CustomField> createState() => _CustomFieldState();
// }
//
// class _CustomFieldState extends State<CustomField> {
//   bool obscure = true;
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(top: 16),
//       child: TextFormField(
//         validator: (value) => value!.isEmpty ? "Required" : null,
//         obscureText: widget.isPass ? obscure : false,
//         controller: widget.controller,
//         // autofocus: true,
//         decoration: InputDecoration(
//           suffixIcon: widget.isPass
//               ? IconButton(
//                   onPressed: () {
//                     setState(() {
//                       obscure = !obscure;
//                     });
//                   },
//                   icon: const Icon(Iconsax.eye))
//               : const SizedBox(),
//           contentPadding: const EdgeInsets.all(16),
//           focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide(color: kPrimaryColor)),
//           labelText: widget.label,
//           prefixIcon: Icon(widget.icon),
//           border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//         ),
//       ),
//     );
//   }
// }

 */
