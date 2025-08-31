// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dartz/dartz.dart' as dartz;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:provider/provider.dart';
import 'package:linkup/config/theme/extensions/app_colors.dart';
import 'package:linkup/config/theme/extensions/app_theme_extension.dart';
import 'package:linkup/core/failures/failure.dart';
import 'package:wiredash/wiredash.dart';

import 'package:linkup/core/domain/entities/user/user_entity.dart';
import 'package:linkup/core/presentation/bloc/user%20blocking/user_blocking_bloc.dart';
import 'package:linkup/features/Chat/domain/entities/chat.dart';
import 'package:linkup/features/Chat/domain/usecases/get_chats_uc.dart';
import 'package:linkup/features/Chat/presentation/bloc/chat_bloc.dart';
import 'package:linkup/features/Chat/presentation/pages/chat_page.dart';
import 'package:linkup/features/Chat/presentation/provider/chats_list_provider.dart';
import 'package:linkup/features/Profile/presentation/bloc/profile/profile_bloc.dart';

import '/injection_container.dart' as di;

class ChatsListPage extends StatefulWidget {
  final String? senderUserID;

  const ChatsListPage({
    super.key,
    this.senderUserID,
  });

  @override
  State<ChatsListPage> createState() => _ChatsListPageState();
}

class _ChatsListPageState extends State<ChatsListPage> {
  List<ChatEntity> pinnedChatsList = [];
  // late final SlidableController _slidableController;

  // final GetUnreadMsgsCountUc _getUnreadMsgsCountUc =
  //     di.sl<GetUnreadMsgsCountUc>();
  final GetChatsUc _getAllChats = di.sl<GetChatsUc>();

  // @override
  // void initState() {
  //   super.initState();
  //   // _slidableController = SlidableController(this);
  // }

  // @override
  // void dispose() {
  //   _slidableController.dispose();
  //   super.dispose();
  // }

  void _showChatDeletionDialog({
    required BuildContext context,
    required UserEntity receiverUser,
    required String chatID,
    required String currentUserID,
  }) {
    showAdaptiveDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          // backgroundColor: AppTheme.backgroundColor,
          title: Text(context.tr("chats_list_page.deletion_title")),
          content: RichText(
            text: TextSpan(
              text: context.tr("chats_list_page.deletion_content"),
              // style: const TextStyle(color: AppTheme.secondaryColor),
              children: [
                TextSpan(
                  text: receiverUser.fullName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    // color: AppTheme.secondaryColor,
                  ),
                ),
                const TextSpan(
                  text: "?",
                  // style: TextStyle(
                  //   color: AppTheme.secondaryColor,
                  // ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                context.tr("core.cancel"),
                // style: const TextStyle(
                //   color: AppTheme.secondaryColor,
                // ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);

                context.read<ChatBloc>().add(DeleteChat(
                      chatID: chatID,
                      receiverUserID: receiverUser.id,
                      currentUserID: currentUserID,
                    ));

                setState(() {});
              },
              child: Text(
                context.tr("chats_list_page.delete_chat"),
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

  void _showUserBlockingDialog({
    required BuildContext context,
    required UserEntity receiverUser,
    required String chatID,
    required String currentUserID,
  }) {
    bool deleteChat = true;

    showAdaptiveDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, updateState) {
            return AlertDialog(
              // backgroundColor: AppTheme.backgroundColor,
              title: Text(
                context.tr(
                  "chats_list_page.blocking_title",
                  namedArgs: {"fullName": receiverUser.fullName},
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RichText(
                    text: TextSpan(
                      text: context.tr("chats_list_page.blocking_content"),
                      // style: const TextStyle(color: AppTheme.secondaryColor),
                      children: [
                        TextSpan(
                          text: receiverUser.fullName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            // color: AppTheme.secondaryColor,
                          ),
                        ),
                        TextSpan(
                          text: context.tr("blocked_users_page.on"),
                          // style: const TextStyle(
                          //   color: AppTheme.secondaryColor,
                          // ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Checkbox(
                        value: deleteChat,
                        // activeColor: AppTheme.primaryColor,
                        onChanged: (value) {
                          updateState(() {
                            deleteChat = !deleteChat;
                          });
                        },
                      ),
                      const SizedBox(width: 10),
                      Text(context.tr("chats_list_page.delete_")),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    context.tr("core.cancel"),
                    // style: const TextStyle(
                    //   color: AppTheme.primaryColor,
                    // ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);

                    if (deleteChat) {
                      context.read<ChatBloc>().add(
                            DeleteChat(
                              chatID: chatID,
                              receiverUserID: receiverUser.id,
                              currentUserID: currentUserID,
                            ),
                          );
                    }

                    context.read<UserBlockingBloc>().add(
                          BlockUserEvent(
                            currentUserID: currentUserID,
                            blockUserID: receiverUser.id,
                          ),
                        );

                    context
                        .read<ProfileBloc>()
                        .add(UpdateUserEvent(blockedUser: receiverUser.id));

                    setState(() {});
                  },
                  child: Text(
                    context.tr("chats_list_page.block_"),
                    style: TextStyle(
                      color: Colors.red[600],
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

  void showMuteStatusSnackBar(bool isMuted) {
    final String msgText = isMuted ? "Chat is muted" : "Chat is unmuted";
    final IconData icon = isMuted
        ? MingCuteIcons.mgc_volume_off_fill
        : MingCuteIcons.mgc_volume_fill;

    Get.rawSnackbar(
      messageText: Text(
        msgText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
      ),
      isDismissible: true,
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.grey[600]!,
      icon: Icon(
        icon,
        color: Colors.white,
        size: 35,
      ),
      margin: EdgeInsets.zero,
      snackStyle: SnackStyle.GROUNDED,
    );
  }

  void showPinStatusSnackBar(bool isPinned) {
    final String msgText = isPinned ? "Chat is pinned" : "Chat is unpinned";
    final IconData icon =
        isPinned ? MingCuteIcons.mgc_pin_2_fill : MingCuteIcons.mgc_pin_fill;

    Get.rawSnackbar(
      messageText: Text(
        msgText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
      ),
      isDismissible: true,
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.grey[600]!,
      icon: Icon(
        icon,
        color: Colors.white,
        size: 35,
      ),
      margin: EdgeInsets.zero,
      snackStyle: SnackStyle.GROUNDED,
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppColors appColors = context.theme.appColors;

    return Scaffold(
        body: SafeArea(
      child: BlocListener<ChatBloc, ChatState>(
        listener: (context, state) {
          if (state is PinnedStatusToggled) {
            showPinStatusSnackBar(state.isPinned);
          } else if (state is MutedStatusToggled) {
            showMuteStatusSnackBar(state.isMuted);
          }
        },
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is GettingUserState) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is GotUserState) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 15),
                  _buildAppBar(appColors),
                  const SizedBox(height: 15),
                  StreamBuilder<dartz.Either<Failure, List<ChatEntity>>>(
                    stream: _getAllChats(state.user!),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData ||
                          snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (snapshot.connectionState ==
                              ConnectionState.done ||
                          snapshot.connectionState == ConnectionState.active) {
                        return snapshot.data!.fold((failure) {
                          return Center(
                            child: Text(context.tr("core.smth_went_wrong")),
                          );
                        }, (chats) {
                          if (chats.isNotEmpty) {
                            final bool isThereAnyPinnedChat =
                                chats.any((chat) => chat.isPinned ?? false);

                            pinnedChatsList = chats
                                .where((chat) => chat.isPinned ?? false)
                                .toList();

                            if (widget.senderUserID != null) {
                              final ChatEntity? chat = chats
                                  .cast<ChatEntity>()
                                  .where((chat) =>
                                      chat.receiverUser.id ==
                                      widget.senderUserID)
                                  .toList()
                                  .firstOrNull;
                              final UserEntity? receiverUser =
                                  chat?.receiverUser;

                              if (receiverUser != null) {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return ChatPage(chatEntity: chat!);
                                }));
                              }
                            }

                            return Expanded(
                              child: Column(
                                children: [
                                  if (isThereAnyPinnedChat)
                                    // Pinned Chats
                                    _buildPinnedChats(appColors),

                                  // All chats
                                  _buildChats(appColors, chats, state.user!.id),
                                ],
                              ),
                            );
                          } else {
                            return Center(
                              child: Text(
                                textAlign: TextAlign.center,
                                context.tr("chats_list_page.no_chats"),
                              ),
                            );
                          }
                        });
                      } else {
                        return Center(
                          child: Text(context.tr("core.smth_went_wrong")),
                        );
                      }
                    },
                  ),
                ],
              );
            } else {
              return Center(
                child: Text(context.tr("core.smth_went_wrong")),
              );
            }
          },
        ),
      ),
    ));
  }

  Widget _buildAppBar(AppColors appColors) {
    return Consumer<ChatsListProvider>(
      builder: (context, provider, child) {
        if (provider.isEditing) {
          return _buildEditingAppBar(appColors, provider);
        } else {
          return _buildDefaultAppBar();
        }
      },
    );
  }

  Widget _buildDefaultAppBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton.icon(
          style: const ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(Colors.transparent),
          ),
          onPressed: () {
            Wiredash.of(context).show(inheritMaterialTheme: true);
          },
          label: Text(
            "Report",
            style: TextStyle(
              color: Colors.red[600],
              fontWeight: FontWeight.normal,
              fontSize: 16,
            ),
          ),
          icon: Icon(
            Icons.bug_report_outlined,
            color: Colors.red[600],
            size: 22,
          ),
          iconAlignment: IconAlignment.end,
        )
      ],
    );
  }

  Widget _buildEditingAppBar(AppColors appColors, ChatsListProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () {
                provider.toggleEditingMode();
              },
              icon: Icon(
                MingCuteIcons.mgc_close_line,
                color: appColors.secondary,
              ),
            ),
            const SizedBox(width: 8),
            Text(provider.selectedChatsIDs.length.toString()),
          ],
        ),
        PopupMenuButton<String>(
          icon: Icon(
            MingCuteIcons.mgc_more_2_line,
            color: appColors.secondary,
          ),
          onSelected: (value) {
            switch (value) {
              case "mark_as_read":
                context.read<ChatBloc>().add(
                      MarkChatsAsRead(chatsIDs: provider.selectedChatsIDs),
                    );

                provider.toggleEditingMode();
                break;
              default:
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: "mark_as_read",
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(MingCuteIcons.mgc_book_6_line),
                  Text("Mark as read"),
                ],
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildPinnedChats(AppColors appColors) {
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10, bottom: 20),
      padding: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: [
                Text(
                  "Pinned Chats",
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: SizedBox(
              height: MediaQuery.of(context).size.height / 8,
              child: ListView.builder(
                itemCount: pinnedChatsList.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  final ChatEntity pinnedChat = pinnedChatsList[index];
                  final String? profileImageUrl =
                      pinnedChat.receiverUser.profileImageUrl;

                  return Padding(
                    padding: const EdgeInsets.only(right: 15),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundImage: profileImageUrl != null
                              ? CachedNetworkImageProvider(
                                  profileImageUrl,
                                )
                              : const AssetImage("assets/icons/user.png")
                                  as ImageProvider<Object>,
                          backgroundColor: appColors.secondary,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          pinnedChat.receiverUser.fullName,
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChats(
      AppColors appColors, List<ChatEntity> chats, String currentUserID) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        padding: const EdgeInsets.only(top: 10),
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: [
                  Text(
                    context.tr("chats_list_page.chats"),
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              flex: 3,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                itemCount: chats.length,
                itemBuilder: (context, index) {
                  final ChatEntity chat = chats[index];

                  return _buildChat(appColors, chat, index, currentUserID);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChat(
      AppColors appColors, ChatEntity chat, int index, String currentUserID) {
    final DateTime? dateTime = chat.lastMessage?.timestamp.toDate();
    final String time =
        dateTime != null ? DateFormat.Hm().format(dateTime.toLocal()) : "";

    final bool isPinned = chat.isPinned ?? false;
    final bool isMuted = chat.isMuted ?? false;
    final int unreadMessagesCount = chat.unreadMessagesCount ?? 0;
    final String? profileImageUrl = chat.receiverUser.profileImageUrl;
    final UserEntity receiverUser = chat.receiverUser;

    String lastMessageText = "";
    if (chat.lastMessage?.message != null) {
      lastMessageText = context.tr(
        "chats_list_page.last_msg",
        namedArgs: {"msg": chat.lastMessage!.message},
      );
    }

    return Consumer<ChatsListProvider>(
      builder: (context, provider, child) {
        final bool isSelected = provider.selectedChatsIDs.contains(chat.chatID);

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (provider.isEditing)
              // checkbox icon instead of close_square
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Icon(
                  isSelected
                      ? MingCuteIcons.mgc_close_square_line
                      : MingCuteIcons.mgc_square_line,
                  color: isSelected ? appColors.primary : appColors.secondary,
                ),
              ),
            Expanded(
              child: Slidable(
                enabled: !provider.isEditing,
                startActionPane: _buildStartActionPane(
                  index: index,
                  isPinned: isPinned,
                  userID: currentUserID,
                  chatID: chat.chatID,
                ),
                endActionPane: _buildEndActionPane(
                  appColors,
                  isMuted: isMuted,
                  chatID: chat.chatID,
                  receiverUser: receiverUser,
                  currentUserID: currentUserID,
                ),
                child: GestureDetector(
                  onLongPress: () {
                    if (!provider.isEditing) {
                      context.read<ChatsListProvider>().toggleEditingMode();

                      context.read<ChatsListProvider>().toggleChat(chat.chatID);
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.grey[850],
                        borderRadius: BorderRadius.circular(2)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.only(bottom: 10),
                      onTap: () {
                        if (!provider.isEditing) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return ChatPage(
                                  chatEntity: chat,
                                );
                              },
                            ),
                          );
                        } else {
                          context
                              .read<ChatsListProvider>()
                              .toggleChat(chat.chatID);
                        }
                      },
                      leading: _buildChatIcon(appColors, profileImageUrl),
                      title: Text(
                        chat.receiverUser.fullName,
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Text(
                        lastMessageText,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 16,
                          color: chat.unreadMessagesCount! > 0
                              ? Colors.white
                              : Colors.grey,
                        ),
                      ),
                      trailing: _buildChatTrailing(
                          appColors, unreadMessagesCount, isMuted, time),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  ActionPane _buildStartActionPane({
    required int index,
    required bool isPinned,
    required String userID,
    required String chatID,
  }) {
    return ActionPane(
      key: ValueKey(index),
      extentRatio: 0.25,
      motion: const StretchMotion(),
      children: [
        SlidableAction(
          borderRadius: BorderRadius.circular(8),
          onPressed: (context) {
            context.read<ChatBloc>().add(
                  SetPinnedStatus(
                      isPinned: isPinned, userID: userID, chatID: chatID),
                );
          },
          backgroundColor: Colors.grey[600]!,
          icon: isPinned
              ? MingCuteIcons.mgc_pin_2_fill
              : MingCuteIcons.mgc_pin_line,
          label: isPinned ? "Unpin" : "Pin", // TODO: Localize
        ),
      ],
    );
  }

  ActionPane _buildEndActionPane(
    AppColors appColors, {
    required bool isMuted,
    required String chatID,
    required UserEntity receiverUser,
    required String currentUserID,
  }) {
    return ActionPane(
      extentRatio: 0.75,
      motion: const StretchMotion(),
      children: [
        SlidableAction(
          borderRadius: BorderRadius.circular(8),
          onPressed: (context) {
            _showChatDeletionDialog(
              context: context,
              receiverUser: receiverUser,
              chatID: chatID,
              currentUserID: currentUserID,
            );
          },
          backgroundColor: Colors.red[600]!,
          icon: MingCuteIcons.mgc_delete_2_line,
          label: context.tr("core.delete"),
        ),
        SlidableAction(
          borderRadius: BorderRadius.circular(8),
          onPressed: (context) {
            _showUserBlockingDialog(
              context: context,
              receiverUser: receiverUser,
              chatID: chatID,
              currentUserID: currentUserID,
            );
          },
          backgroundColor: Colors.grey[800]!,
          icon: MingCuteIcons.mgc_forbid_circle_line,
          label: context.tr("chats_list_page.block"),
        ),
        SlidableAction(
          borderRadius: BorderRadius.circular(8),
          onPressed: (context) {
            context.read<ChatBloc>().add(
                  SetMuteStatus(
                    isMuted: isMuted,
                    userID: currentUserID,
                    chatID: chatID,
                  ),
                );
          },
          backgroundColor: appColors.secondary,
          icon: isMuted
              ? MingCuteIcons.mgc_volume_line
              : MingCuteIcons.mgc_volume_off_line,
          label: isMuted ? "Unmute" : "Mute", // TODO: Localize
        ),
      ],
    );
  }

  Widget _buildChatIcon(AppColors appColors, String? profileImageUrl) {
    return Container(
      height: 48,
      width: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: appColors.secondary,
          width: 1.0,
        ),
      ),
      child: ClipOval(
        child: profileImageUrl == null
            ? const Icon(
                Icons.person_outline_rounded,
                size: 36,
              )
            : CircleAvatar(
                radius: 18,
                backgroundImage: CachedNetworkImageProvider(
                  profileImageUrl,
                ),
              ),
      ),
    );
  }

  Widget _buildChatTrailing(
      AppColors appColors, int unreadMessagesCount, bool isMuted, String time) {
    return Column(
      children: [
        // Time when the message was last sent
        Text(
          time,
          style: const TextStyle(
            fontSize: 14,
          ),
        ),

        // Amount of unread messages
        if (unreadMessagesCount > 0)
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: !isMuted ? Colors.grey : appColors.primary,
              ),
              child: Text(
                textAlign: TextAlign.center,
                unreadMessagesCount.toString(),
                style: TextStyle(
                  fontSize: 14,
                  color: appColors.background,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
