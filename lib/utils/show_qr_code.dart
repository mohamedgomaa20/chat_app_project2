import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../widgets/custom_elevated_button.dart';

class ShowQRCode extends StatelessWidget {
  const ShowQRCode({
    super.key,
    required this.data,
  });

  final data;

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () {
          showBottomSheet(
            elevation: 200,
            context: context,
            builder: (context) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  border: BorderDirectional(
                    top: BorderSide(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        width: 3),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Gap(16),
                    Center(
                      child: Column(
                        children: [
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(30.0),
                              child: Card(
                                color: Colors.white,
                                child: QrImageView(
                                  data: data,
                                  version: 3,
                                  size: 200.0,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(20),
                    CustomElevatedButton(
                      text: 'Done',
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    )
                  ],
                ),
              );
            },
          );
        },
        icon: const Icon(Iconsax.scan_barcode));
  }
}
