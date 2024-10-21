import 'dart:io';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';

import '../../../widgets/text_form_field.dart';

class GroupHeader extends StatelessWidget {
  final String groupName;
  final String groupImage;
  final Function() onImagePick;

  const GroupHeader({
    Key? key,
    required this.groupName,
    required this.groupImage,
    required this.onImagePick,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              groupImage.isEmpty
                  ? const CircleAvatar(
                      radius: 40,
                      child: Icon(
                        Iconsax.user,
                        size: 20,
                      ),
                    )
                  : CircleAvatar(
                      radius: 40,
                      backgroundImage: groupImage.startsWith('http')
                          ? NetworkImage(
                              groupImage) // دعم تحميل الصورة من الإنترنت
                          : FileImage(File(groupImage)) as ImageProvider,
                    ),
              Positioned(
                bottom: -10,
                right: -10,
                child: IconButton(
                  onPressed: onImagePick,
                  icon: const Icon(
                    Iconsax.edit,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: CustomTextFormField(
            controller: TextEditingController(text: groupName),
            prefixIcon: Iconsax.user_octagon,
            label: "Group Name",
          ),
        ),
      ],
    );
  }
}

//create
/*
GroupHeader(
  groupName: gNameCon.text,
  groupImage: _groupImage,
  onImagePick: () async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _groupImage = pickedFile.path;
      });
    }
  },
),



// edit

GroupHeader(
  groupName: gNameCon.text,
  groupImage: _selectedImage != null ? _selectedImage!.path : widget.chatGroup.image!,
  onImagePick: _pickImage,
),


 */
