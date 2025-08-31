// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:intl/intl.dart';
import 'package:linkup/config/theme/extensions/app_colors.dart';
import 'package:linkup/config/theme/extensions/app_theme_extension.dart';
import 'package:linkup/config/theme/theme_getter.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isCurrentUser;
  final Timestamp timestamp;
  final bool isEditing;
  final bool isSelected;
  final bool isReplyed;
  final Map<String, dynamic>? reply;
  final bool isMsgVerified;
  final Function() onPressed;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
    required this.timestamp,
    required this.isEditing,
    required this.isSelected,
    required this.isReplyed,
    required this.reply,
    required this.isMsgVerified,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    DateTime dateTime = timestamp.toDate();
    String time = DateFormat.Hm().format(dateTime.toLocal());
    String date = DateFormat("MMMM dd").format(dateTime.toLocal());

    final AppColors appColors = context.theme.appColors;

    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? const Color.fromARGB(255, 51, 51, 51)
            : Colors.transparent,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Row(
          children: [
            if (isEditing)
              Row(
                children: [
                  isSelected
                      ? Icon(
                          Icons.check_circle_outline_rounded,
                          color: appColors.primary,
                        )
                      : const Icon(Icons.circle_outlined),
                  const SizedBox(width: 10),
                ],
              ),
            if (!isMsgVerified)
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: onPressed,
                  child: Icon(
                    MingCuteIcons.mgc_warning_fill,
                    color: Colors.red[600],
                  ),
                ),
              ),
            Expanded(
              child: Row(
                mainAxisAlignment: !isCurrentUser
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.end,
                children: [
                  if (isCurrentUser)
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Text(
                        time,
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  // if (index == 0) const Spacer(),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.7,
                      ),
                      decoration: BoxDecoration(
                        color: !isCurrentUser
                            ? Colors.grey[800]
                            : appColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      // alignment: index == 1
                      //     ? Alignment.centerLeft
                      //     : Alignment.centerRight,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isReplyed)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 6),
                                decoration: BoxDecoration(
                                  color: !isCurrentUser
                                      ? Colors.grey[700]
                                      : const Color.fromARGB(
                                          255, 216, 251, 200),
                                  border: BorderDirectional(
                                    start: BorderSide(
                                      color: !isCurrentUser
                                          ? appColors.secondary
                                          : Colors.black,
                                      width: 2.0,
                                    ),
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      reply!["replyTo"],
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: TextStyle(
                                        color: !isCurrentUser
                                            ? appColors.secondary
                                            : Colors.black,
                                      ),
                                    ),
                                    Text(
                                      reply!["replyMessage"],
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: TextStyle(
                                        color: !isCurrentUser
                                            ? appColors.secondary
                                            : Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          Text(
                            message,
                            softWrap: true,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              color:
                                  !isCurrentUser ? Colors.white : Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // if (index == 1) const Spacer(),
                  if (!isCurrentUser)
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        time,
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
