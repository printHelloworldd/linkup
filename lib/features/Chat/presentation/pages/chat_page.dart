import 'package:clipboard/clipboard.dart';
import 'package:dartz/dartz.dart' as dartz;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:provider/provider.dart';
import 'package:linkup/config/theme/extensions/app_colors.dart';
import 'package:linkup/config/theme/extensions/app_theme_extension.dart';
import 'package:linkup/config/theme/theme_getter.dart';
import 'package:linkup/core/data/datasources/remote/database_datasource.dart';
import 'package:linkup/core/data/repository/database_repository_impl.dart';
import 'package:linkup/core/domain/entities/user/user_entity.dart';
import 'package:linkup/core/domain/usecases/real%20time%20database/get_user_status_uc.dart';
import 'package:linkup/core/domain/usecases/real%20time%20database/get_user_typing_status_uc.dart';
import 'package:linkup/core/domain/usecases/real%20time%20database/update_typing_status_uc.dart';
import 'package:linkup/core/failures/failure.dart';
import 'package:linkup/core/presentation/bloc/user%20blocking/user_blocking_bloc.dart';
import 'package:linkup/features/Chat/domain/entities/message.dart';
import 'package:linkup/features/Chat/presentation/widgets/block_info_panel.dart';
import 'package:linkup/features/Chat/presentation/widgets/unblock_button.dart';
import 'package:linkup/features/Profile/presentation/pages/user_profile_page.dart';
import 'package:linkup/features/Chat/domain/entities/chat.dart';
import 'package:linkup/features/Chat/domain/usecases/get_messages_uc.dart';
import 'package:linkup/features/Chat/presentation/bloc/chat_bloc.dart';
import 'package:linkup/features/Chat/presentation/provider/chat_provider.dart';
import 'package:linkup/features/Chat/presentation/widgets/chat_bubble.dart';
import 'package:linkup/features/Profile/presentation/bloc/profile/profile_bloc.dart';
import 'package:swipe_to/swipe_to.dart';
import '/injection_container.dart' as di;

class ChatPage extends StatefulWidget {
  final ChatEntity chatEntity;

  const ChatPage({
    super.key,
    required this.chatEntity,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final GetMessagesUc getMessagesUc = di.sl<GetMessagesUc>();

  final TextEditingController _messageController = TextEditingController();
  final FocusNode _messageFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  late final UserEntity receiverUser;
  late final UserEntity currentUser;

  late bool isUserBlocked;
  late bool isCurrentUserBlocked;

  @override
  void initState() {
    receiverUser = widget.chatEntity.receiverUser;
    currentUser = context.read<ProfileBloc>().cachedUserData!;

    // context.read<ChatBloc>().add(
    //     GetAllMessages(currentUser: currentUser, otherUserID: receiverUser.id));

    _messageController.addListener(_onTextChanged);
    _messageFocusNode.addListener(_onFocusChanged);

    Future.delayed(
      const Duration(milliseconds: 500),
      () => _scrollDown(),
    );

    isUserBlocked = currentUser.blockedUsers.contains(receiverUser.id);
    isCurrentUserBlocked = receiverUser.blockedUsers.contains(currentUser.id);

    super.initState();
  }

  void _scrollDown() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 1),
        curve: Curves.fastOutSlowIn,
      );
    }
  }

  void _jumpDown() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(
        _scrollController.position.maxScrollExtent,
      );
    }
  }

  void _onFocusChanged() {
    if (_messageFocusNode.hasFocus) {
      Future.delayed(
        const Duration(milliseconds: 500),
        () => _scrollDown(),
      );
    }
  }

  void _onTextChanged() {
    if (_messageController.text.isNotEmpty) {
      if (!_isTyping) {
        _setTypingStatus(
            true); // Вызываем ОДИН раз, когда пользователь начал печатать
      }
    } else {
      _setTypingStatus(false); // Если поле пустое, сразу ставим false
    }
  }

  void _setTypingStatus(bool typing) {
    if (_isTyping == typing) return; // Избегаем лишних вызовов

    _isTyping = typing;

    UpdateTypingStatusUc(DatabaseRepositoryImpl(DatabaseDatasource()))
        .call(typing);
  }

  void _copyMessageText(AppColors appColors) {
    final selectedMessages = context.read<ChatProvider>().selectedMessages;

    if (selectedMessages.isEmpty) return;

    // Sort messages by time (oldest to newest)
    selectedMessages.sort((a, b) => a["timestamp"].compareTo(b["timestamp"]));
    if (kDebugMode) {
      print(selectedMessages);
    }

    // Grouping messages by senders
    List<String> receiverMessages = [];
    List<String> currentUserMessages = [];

    for (var message in selectedMessages) {
      if (message["senderID"] == receiverUser.id) {
        receiverMessages.add(message["text"]);
      } else {
        currentUserMessages.add(message["text"]);
      }
    }

    // Determine the order: whoever sent the message first goes first
    String copiedText = "";
    if (selectedMessages.length > 1) {
      if (selectedMessages.first["senderID"] == receiverUser.id) {
        if (receiverMessages.isNotEmpty) {
          copiedText +=
              "${receiverUser.fullName}:\n${receiverMessages.join("\n\n")}\n\n";
        }
        if (currentUserMessages.isNotEmpty) {
          copiedText +=
              "${currentUser.fullName}:\n${currentUserMessages.join("\n\n")}";
        }
      } else {
        if (currentUserMessages.isNotEmpty) {
          copiedText +=
              "${currentUser.fullName}:\n${currentUserMessages.join("\n\n")}\n\n";
        }
        if (receiverMessages.isNotEmpty) {
          copiedText +=
              "${receiverUser.fullName}:\n${receiverMessages.join("\n\n")}";
        }
      }
    } else {
      copiedText = selectedMessages.single["text"];
    }

    // Copy to clipboard
    FlutterClipboard.copy(copiedText);

    Fluttertoast.showToast(
      msg: context.tr("chat_page.text_copied"),
      backgroundColor: appColors.primary,
      textColor: Colors.black,
      fontSize: 14,
    );
  }

  void _deleteMessages(AppColors appColors) {
    final selectedMessages = context.read<ChatProvider>().selectedMessages;

    String title = "";
    String content = "";

    if (selectedMessages.length > 1) {
      title = context.tr(
        "chat_page.delete_msgs_title",
        namedArgs: {
          "count": selectedMessages.length.toString(),
        },
      );
      content = context.tr("chat_page.delete_msgs_content");
    } else {
      title = context.tr("chat_page.delete_msg_title");
      content = context.tr("chat_page.delete_msg_content");
    }

    showAdaptiveDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: appColors.background,
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                context.tr("core.cancel"),
                style: TextStyle(
                  color: appColors.primary,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                context.read<ChatBloc>().add(
                      DeleteMessage(
                        receiverID: receiverUser.id,
                        messageIDs: selectedMessages
                            .map((message) => message["id"] as String)
                            .toList(),
                      ),
                    );

                context.read<ChatProvider>().toggleEditingMode();

                Navigator.pop(context);
              },
              child: Text(
                context.tr("core.delete"),
                style: TextStyle(
                  color: Colors.red[600],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showMsgVerificationWarning(AppColors appColors, BuildContext context) {
    showAdaptiveDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: appColors.background,
          title: const Text("Verification error"),
          content: const Text(
              "The message could not be verified. This may mean that the message has been modified or sent by the wrong sender. Please make sure that the message comes from a trusted source."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                context.tr("core.ok"),
                style: TextStyle(
                  color: appColors.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showUserUnblockingDialog(
    AppColors appColors, {
    required BuildContext context,
    required UserEntity receiverUser,
    required String currentUserID,
  }) {
    showAdaptiveDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, updateState) {
            return AlertDialog(
              backgroundColor: appColors.background,
              title: Text(
                context.tr(
                  "blocked_users_page.alert_title",
                  namedArgs: {"fullName": receiverUser.fullName},
                ),
              ),
              content: RichText(
                text: TextSpan(
                  text: context.tr("blocked_users_page.alert_content"),
                  style: TextStyle(color: appColors.secondary),
                  children: [
                    TextSpan(
                      text: receiverUser.fullName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: appColors.secondary,
                      ),
                    ),
                    TextSpan(
                      text: context.tr("blocked_users_page.on"),
                      style: TextStyle(
                        color: appColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    context.tr("core.cancel"),
                    style: TextStyle(
                      color: appColors.secondary,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    context.read<UserBlockingBloc>().add(
                          UnblockUserEvent(
                            currentUserID: currentUserID,
                            blockedUserID: receiverUser.id,
                          ),
                        );

                    context
                        .read<ProfileBloc>()
                        .add(UpdateUserEvent(blockedUser: receiverUser.id));

                    setState(() {
                      isUserBlocked = false;
                    });

                    Navigator.pop(context);
                  },
                  child: Text(
                    context.tr("blocked_users_page.unblock_user"),
                    style: TextStyle(
                      color: appColors.primary,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _messageController.removeListener(_onTextChanged);
    _messageController.dispose();

    _messageFocusNode.removeListener(_onFocusChanged);
    _messageFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppColors appColors = context.theme.appColors;

    return Scaffold(
      appBar: _buildAppBar(appColors),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // All messages
            StreamBuilder<dartz.Either<Failure, List<MessageEntity>>>(
                stream: getMessagesUc(currentUser, widget.chatEntity),
                builder: (context, snapshot) {
                  if (!snapshot.hasData ||
                      snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else {
                    return snapshot.data!.fold((failure) {
                      return Center(
                        child: Text(context.tr("core.smth_went_wrong")),
                      );
                    }, (messages) {
                      if (messages.isEmpty) {
                        return Center(
                            child: Text(context.tr("chat_page.no_msg")));
                      } else {
                        return _buildMessages(appColors, messages);
                      }
                    });
                  }
                }),

            _buildBottomPanel(appColors),
          ],
        ),
      ),
    );
  }

  Widget _buildMessages(AppColors appColors, List<MessageEntity> messages) {
    return Expanded(
      child: ListView(
        controller: _scrollController,
        children: messages.map((message) {
          String messageID = message.id;
          String messageText = message.message;
          String senderID = message.senderID;
          final messageTimestamp = message.timestamp;

          // if (currentUser.id == senderID) {
          //   messageText = message.senderMessage;
          // } else {
          //   messageText = message.receiverMessage;
          // }

          // print(messageText);

          return Consumer<ChatProvider>(
            builder: (context, chatProvider, child) {
              return GestureDetector(
                onLongPress: () {
                  if (!chatProvider.isEditing) {
                    chatProvider.toggleEditingMode();
                    chatProvider.toggleMessage(
                        messageID, messageText, messageTimestamp, senderID);
                  }
                },
                onTap: () {
                  if (chatProvider.isEditing) {
                    chatProvider.toggleMessage(
                        messageID, messageText, messageTimestamp, senderID);
                  }
                },
                child: SwipeTo(
                  animationDuration: const Duration(
                    milliseconds: 300,
                  ),
                  onLeftSwipe: (details) {
                    chatProvider.toggleReplyingMode(true);
                    String replyTo = "";

                    if (senderID == receiverUser.id) {
                      replyTo = receiverUser.fullName;
                    } else {
                      replyTo = currentUser.fullName;
                    }

                    chatProvider.changeReplyData(replyTo, messageText);
                  },
                  child: ChatBubble(
                    message: messageText,
                    isCurrentUser: senderID == currentUser.id,
                    timestamp: messageTimestamp,
                    isEditing: chatProvider.isEditing,
                    isSelected: chatProvider.selectedMessages
                        .any((message) => message["id"] == messageID),
                    isReplyed:
                        message.reply?["replyMessage"].isNotEmpty ?? false,
                    reply: message.reply,
                    isMsgVerified: message.isVerified ?? false,
                    onPressed: () =>
                        _showMsgVerificationWarning(appColors, context),
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(AppColors appColors) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: Consumer<ChatProvider>(
        builder: (context, value, child) {
          if (value.isEditing) {
            return _editingAppBar(appColors, value);
          } else {
            return _defaultAppBar(appColors);
          }
        },
      ),
    );
  }

  AppBar _defaultAppBar(AppColors appColors) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      forceMaterialTransparency: true,
      toolbarHeight: 75,
      leading: IconButton(
        onPressed: () async {
          // await Future.delayed(Duration(milliseconds: 500));
          Navigator.pop(context);
          // Navigator.popUntil(context, ModalRoute.withName("/chats_list_page"));
        },
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
      ),
      title: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserProfilePage(
                user: receiverUser,
                navigatedFromChatPage: true,
              ),
            ),
          );
        },
        child: Column(
          children: [
            Text(receiverUser.fullName),
            StreamBuilder<bool>(
              stream:
                  GetUserStatusUc(DatabaseRepositoryImpl(DatabaseDatasource()))
                      .call(receiverUser.id),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data!) {
                    return StreamBuilder<bool>(
                        stream: GetUserTypingStatusUc(
                                DatabaseRepositoryImpl(DatabaseDatasource()))
                            .call(receiverUser.id),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            if (snapshot.data!) {
                              return Text(
                                context.tr("chat_page.typing"),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: appColors.primary,
                                ),
                              );
                            } else {
                              return Text(
                                context.tr("chat_page.online"),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: appColors.secondary,
                                ),
                              );
                            }
                          } else {
                            return Text(
                              context.tr("chat_page.online"),
                              style: TextStyle(
                                fontSize: 16,
                                color: appColors.secondary,
                              ),
                            );
                          }
                        });
                  } else {
                    return Text(
                      context.tr("chat_page.offline"),
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[500],
                      ),
                    );
                  }
                } else {
                  return Text(
                    context.tr("chat_page.offline"),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[500],
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
      centerTitle: true,
      // actions: [
      //   IconButton(
      //     onPressed: () {},
      //     icon: const Icon(Icons.more_horiz),
      //   )
      // ],
    );
  }

  AppBar _editingAppBar(AppColors appColors, ChatProvider chatProvider) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      forceMaterialTransparency: true,
      toolbarHeight: 75,
      leading: IconButton(
        onPressed: () {
          chatProvider.toggleEditingMode();
        },
        icon: Icon(
          MingCuteIcons.mgc_close_line,
          color: appColors.secondary,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            _copyMessageText(appColors);
            chatProvider.toggleEditingMode();
          },
          icon: Icon(
            MingCuteIcons.mgc_documents_line,
            color: appColors.secondary,
          ),
        ),
        // IconButton(
        //   onPressed: () {},
        //   icon: const Iconify(
        //     Quill.reply,
        //     color: appColors.secondary,
        //   ),
        // ),
        IconButton(
          onPressed: () {
            _deleteMessages(appColors);
          },
          icon: Icon(
            MingCuteIcons.mgc_delete_2_line,
            color: appColors.secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomPanel(AppColors appColors) {
    if (isUserBlocked) {
      return _buildUnblockButton(appColors);
    } else if (isCurrentUserBlocked) {
      return _buildBlockInfoPanel();
    } else {
      return _buildUserInputPanel(appColors);
    }
  }

  Widget _buildUserInputPanel(AppColors appColors) {
    return Consumer<ChatProvider>(builder: (context, chatProvider, child) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 25),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: appColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              if (chatProvider.isReplying)
                Row(
                  children: [
                    const SizedBox(width: 5),
                    Icon(
                      MingCuteIcons.mgc_mail_send_line, // Quill.replyall,
                      color: appColors.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            color: appColors.primary,
                            width: 2,
                            height: 30,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.tr(
                                    "chat_page.reply",
                                    namedArgs: {"who": chatProvider.replyTo},
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                    color: appColors.primary,
                                  ),
                                ),
                                Text(
                                  chatProvider.replyMessage,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                    color: appColors.secondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: () {
                        context.read<ChatProvider>().toggleReplyingMode(false);
                      },
                      icon: Icon(
                        MingCuteIcons.mgc_close_line,
                        color: appColors.primary,
                      ),
                    ),
                  ],
                ),
              Row(
                children: [
                  // IconButton(
                  //   onPressed: () {},
                  //   icon: Icon(
                  //     Typicons.plus,
                  //     color: Colors.grey[500],
                  //   ), // Typicons.link
                  // ),
                  // const SizedBox(width: 10),
                  // Container(
                  //   color: Colors.grey[500],
                  //   width: 2,
                  //   height: 30,
                  // ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      focusNode: _messageFocusNode,
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: null,
                      decoration: InputDecoration(
                        fillColor: appColors.surface,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        hintText: context.tr("chat_page.input_hint"),
                        border: InputBorder.none,
                      ),
                      keyboardType: TextInputType.text,
                    ),
                  ),
                  const SizedBox(width: 10),
                  // IconButton(
                  //   onPressed: () {},
                  //   icon: Icon(
                  //     Typicons.microphone_outline,
                  //     color: Colors.grey[500],
                  //   ),
                  // ),
                  IconButton(
                    onPressed: () {
                      if (_messageController.text.isNotEmpty) {
                        context.read<ChatBloc>().add(
                              SendMessage(
                                receiverUser: receiverUser,
                                senderUser: currentUser,
                                message: _messageController.text,
                                chat: widget.chatEntity,
                                reply: {
                                  "replyTo": chatProvider.replyTo,
                                  "replyMessage": chatProvider.replyMessage,
                                },
                                senderName: currentUser.fullName,
                                receiverFCMToken: receiverUser
                                        .restrictedDataEntity?.fcmToken ??
                                    "",
                              ),
                            );

                        _messageController.clear();

                        context.read<ChatProvider>().toggleReplyingMode(false);

                        _scrollDown();
                      }
                    },
                    icon: Icon(
                      MingCuteIcons.mgc_send_fill,
                      color: appColors.surfaceHighlight,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildUnblockButton(AppColors appColors) {
    return UnblockButton(onTap: () {
      _showUserUnblockingDialog(appColors,
          context: context,
          receiverUser: receiverUser,
          currentUserID: currentUser.id);
    });
  }

  Widget _buildBlockInfoPanel() {
    return const BlockInfoPanel();
  }
}
