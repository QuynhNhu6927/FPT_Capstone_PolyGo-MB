// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:palette_generator/palette_generator.dart';
// import 'package:polygo_mobile/features/home/widgets/social/react_popup.dart';
// import 'package:polygo_mobile/features/home/widgets/social/update_post_dialog.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../../../core/api/api_client.dart';
// import '../../../../core/localization/app_localizations.dart';
// import '../../../../core/utils/audioplayers.dart';
// import '../../../../core/utils/render_utils.dart';
// import '../../../../data/models/post/post_model.dart';
// import '../../../../data/repositories/post_repository.dart';
// import '../../../../data/services/apis/post_service.dart';
// import '../../../../routes/app_routes.dart';
// import 'comment_popup.dart';
//
// class PostCard extends StatefulWidget {
//   final PostModel post;
//   final String avatarUrl;
//   final String userName;
//   final String timeAgo;
//   final String? contentText;
//   final String? contentImage;
//   final int reactCount;
//   final int commentCount;
//   final void Function(String postId)? onPostDeleted;
//   final void Function(PostModel updatedPost)? onPostUpdated;
//
//   final void Function(String postId, String? newMyReaction)? onMyReactionChanged;
//
//   const PostCard({
//     super.key,
//     required this.post,
//     required this.avatarUrl,
//     required this.userName,
//     required this.timeAgo,
//     this.contentText,
//     this.contentImage,
//     required this.reactCount,
//     required this.commentCount,
//     this.onMyReactionChanged,
//     this.onPostDeleted,
//     this.onPostUpdated,
//   });
//
//   @override
//   State<PostCard> createState() => _PostCardState();
// }
//
// class _PostCardState extends State<PostCard> {
//   int? _selectedReaction;
//   late int _reactCount;
//   late final PostRepository _postRepository;
//   List<Color?> _imageBgColors = [];
//   late int _commentCount;
//
//   @override
//   void initState() {
//     super.initState();
//     _postRepository = PostRepository(PostService(ApiClient()));
//     _reactCount = widget.reactCount;
//     _selectedReaction = _reactionIndexFromName(widget.post.myReaction);
//     _commentCount = widget.commentCount;
//     _imageBgColors = List<Color?>.filled(widget.post.imageUrls.length, null);
//
//     for (int i = 0; i < widget.post.imageUrls.length; i++) {
//       getDominantColor(widget.post.imageUrls[i]).then((color) {
//         if (!mounted) return;
//         setState(() {
//           _imageBgColors[i] = color;
//         });
//       });
//     }
//   }
//
//   Future<void> _deletePost() async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token');
//     if (token == null) return;
//
//     final postId = widget.post.id;
//     final loc = AppLocalizations.of(context);
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: Text(loc.translate("confirm")),
//         content: Text(loc.translate("confirm_delete_post")),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(false),
//             child: Text(loc.translate('cancel')),
//           ),
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(true),
//             child: Text(loc.translate("delete"), style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//
//     if (confirm != true) return;
//
//     try {
//       final response = await _postRepository.deletePost(token: token, postId: postId);
//
//       if (response.message?.contains("Success.Delete") == true) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(loc.translate("delete_post_success"))),
//         );
//
//         widget.onPostDeleted?.call(widget.post.id);
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(response.message ?? loc.translate("delete_post_failed"))),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(loc.translate("delete_post_failed"))),
//       );
//     }
//   }
//
//   Future<Color> getDominantColor(String imageUrl) async {
//     final PaletteGenerator paletteGenerator =
//     await PaletteGenerator.fromImageProvider(
//       NetworkImage(imageUrl),
//       maximumColorCount: 20,
//     );
//     return paletteGenerator.dominantColor?.color ?? Colors.grey[200]!;
//   }
//
//   Future<void> _handleReaction(int index) async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token');
//     if (token == null) return;
//
//     final postId = widget.post.id;
//     final selectedReaction = ReactionType.values[index];
//
//     try {
//       if (_selectedReaction == index) {
//         await _postRepository.unReact(token: token, postId: postId);
//         setState(() {
//           _selectedReaction = null;
//           if (_reactCount > 0) _reactCount--;
//         });
//
//         widget.onMyReactionChanged?.call(postId, null);
//       } else {
//         await _postRepository.react(
//           token: token,
//           postId: postId,
//           reactionType: selectedReaction.name,
//         );
//         setState(() {
//           CallSoundManager().playReactPost();
//           if (_selectedReaction == null) {
//             _reactCount++;
//           }
//           _selectedReaction = index;
//         });
//         widget.onMyReactionChanged?.call(postId, selectedReaction.name);
//       }
//     } catch (e) {
//       print("React/UnReact failed: $e");
//     }
//   }
//
//   int? _reactionIndexFromName(String? name) {
//     if (name == null) return null;
//     for (int i = 0; i < ReactionType.values.length; i++) {
//       if (ReactionType.values[i].name == name) return i;
//     }
//     return null;
//   }
//
//   String _timeAgo(DateTime dateTime) {
//     final diff = DateTime.now().difference(dateTime);
//     final loc = AppLocalizations.of(context);
//     if (diff.inSeconds < 60) return loc.translate("just_now");
//     if (diff.inMinutes < 60) return '${diff.inMinutes} ${loc.translate("minutes_ago")}';
//     if (diff.inHours < 24) return '${diff.inHours} ${loc.translate("hours_ago")}';
//     if (diff.inDays < 7) return '${diff.inDays} ${loc.translate("days_ago")}';
//     if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} ${loc.translate("weeks_ago")}';
//     if (diff.inDays < 365) return '${(diff.inDays / 30).floor()} ${loc.translate("months_ago")}';
//     return '${(diff.inDays / 365).floor()} ${loc.translate("year_ago")}';
//   }
//
//   final List<Map<String, dynamic>> _reactions = [
//     {'asset': 'like.png', 'color': Colors.blue},
//     {'asset': 'heart.png', 'color': Colors.red},
//     {'asset': 'haha.png', 'color': Colors.orange},
//     {'asset': 'surprised.png', 'color': Colors.amber},
//     {'asset': 'sad.png', 'color': Colors.indigo},
//     {'asset': 'angry.png', 'color': Colors.deepOrange},
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;
//     final Color textColor = isDark ? Colors.white70 : Colors.black87;
//     final Color secondaryText = isDark ? Colors.white54 : Colors.grey[700]!;
//     final Color imageBgColor = isDark ? Colors.grey[800]! : Colors.grey[200]!;
//
//     final screenWidth = MediaQuery.of(context).size.width;
//     final double reactionIconSize = screenWidth > 600 ? 40 : 24;
//     final double reactionIconPadding = screenWidth > 380 ? 6 : 6;
//     final double reactionIconMargin = screenWidth > 380 ? 10 : 10;
//
//     final double footerIconSize = screenWidth > 600 ? 23 : 18;
//     final double footerTextSize = screenWidth > 380 ? 16 : 14;
//     final double footerSpacing = screenWidth > 380 ? 25 : 20;
//     final loc = AppLocalizations.of(context);
//
//     final Gradient cardBackground = isDark
//         ? const LinearGradient(
//       colors: [Color(0xFF1E1E1E), Color(0xFF2C2C2C)],
//       begin: Alignment.topLeft,
//       end: Alignment.bottomRight,
//     )
//         : const LinearGradient(colors: [Colors.white, Colors.white]);
//
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       decoration: BoxDecoration(
//         gradient: cardBackground,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: isDark ? Colors.black.withOpacity(0.1) : Colors.black.withOpacity(0.1),
//             blurRadius: 8,
//             offset: const Offset(0, 4),
//           )
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(16),
//         child: Padding(
//           padding: const EdgeInsets.all(12),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   GestureDetector(
//                     onTap: () {
//                       Navigator.pushNamed(
//                         context,
//                         AppRoutes.userProfile,
//                         arguments: {'id': widget.post.creator.id},
//                       );
//                     },
//                     child: CircleAvatar(
//                       radius: 22,
//                       backgroundImage: widget.avatarUrl.isNotEmpty
//                           ? NetworkImage(widget.avatarUrl)
//                           : null,
//                       backgroundColor: Colors.grey[700],
//                       child: widget.avatarUrl.isEmpty
//                           ? const Icon(Icons.person, color: Colors.white)
//                           : null,
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Wrap(
//                           crossAxisAlignment: WrapCrossAlignment.center,
//                           children: [
//                             Text(
//                               widget.userName,
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 15,
//                                 color: textColor,
//                               ),
//                             ),
//                             if (widget.post.imageUrls.isNotEmpty) ...[
//                               SizedBox(width: 4),
//                               Text(
//                                 loc.translate("has_post_img"),
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.normal,
//                                   fontSize: 13,
//                                   color: secondaryText,
//                                 ),
//                               ),
//                               Text(
//                                 '${widget.post.imageUrls.length} ${loc.translate("img")}',
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 13,
//                                   color: secondaryText,
//                                 ),
//                               ),
//                             ],
//                           ],
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           _timeAgo(widget.post.createdAt),
//                           style: TextStyle(color: secondaryText, fontSize: 12),
//                         ),
//                       ],
//                     ),
//                   ),
//                   widget.post.isMyPost
//                       ? PopupMenuButton<String>(
//                     icon: Icon(Icons.settings,
//                         color: isDark ? Colors.white54 : Colors.grey),
//                     onSelected: (value) {
//                       if (value == 'edit') {
//                         Navigator.of(context).push(
//                           MaterialPageRoute(
//                             builder: (_) => UpdatePostDialog(
//                               userAvatar: widget.avatarUrl,
//                               postId: widget.post.id,
//                               onUpdated: () async {
//                                 final prefs = await SharedPreferences.getInstance();
//                                 final token = prefs.getString('token');
//                                 if (token == null) return;
//
//                                 final repo = PostRepository(PostService(ApiClient()));
//                                 final res = await repo.getPostDetail(
//                                     token: token, postId: widget.post.id);
//                                 if (!mounted || res.data == null) return;
//                                 widget.onPostUpdated?.call(res.data!);
//
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   SnackBar(
//                                       content:
//                                       Text(loc.translate("edit_post_success"))),
//                                 );
//                               },
//                             ),
//                           ),
//                         );
//                       } else if (value == 'delete') {
//                         _deletePost();
//                       }
//                     },
//                     offset: const Offset(0, 40),
//                     itemBuilder: (context) => [
//                       PopupMenuItem(
//                         value: 'edit',
//                         child: Text(loc.translate("edit")),
//                       ),
//                       PopupMenuItem(
//                         value: 'delete',
//                         child: Text(loc.translate("delete")),
//                       ),
//                     ],
//                   )
//                       : IconButton(
//                     onPressed: () {},
//                     icon: Icon(Icons.flag_outlined,
//                         color: isDark ? Colors.white54 : Colors.grey),
//                   ),
//                 ],
//               ),
//
//               const SizedBox(height: 12),
//
//               if (widget.contentText != null && widget.contentText!.isNotEmpty)
//                 Padding(
//                   padding: const EdgeInsets.only(bottom: 8),
//                   child: RenderUtils.selectableMarkdownText(context, widget.contentText),
//                 ),
//               if (widget.post.imageUrls.isNotEmpty)
//                 LayoutBuilder(
//                   builder: (context, constraints) {
//                     final width = constraints.maxWidth;
//                     final height = width * 0.6;
//                     return SizedBox(
//                       height: height,
//                       child: PageView.builder(
//                         scrollDirection: Axis.horizontal,
//                         itemCount: widget.post.imageUrls.length,
//                         itemBuilder: (context, index) {
//                           final imageUrl = widget.post.imageUrls[index];
//                           return GestureDetector(
//                             onTap: () => _showFullImage(context, imageUrl),
//                             child: Container(
//                               margin: const EdgeInsets.symmetric(horizontal: 4),
//                               decoration: BoxDecoration(
//                                 color: (_imageBgColors[index] ?? imageBgColor).withOpacity(0.3),
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               child: ClipRRect(
//                                 borderRadius: BorderRadius.circular(12),
//                                   child: Image.network(
//                                     imageUrl,
//                                     width: width,
//                                     height: height,
//                                     fit: BoxFit.contain,
//                                     cacheWidth: (width * MediaQuery.of(context).devicePixelRatio).toInt(),
//                                     cacheHeight: (height * MediaQuery.of(context).devicePixelRatio).toInt(),
//                                     loadingBuilder: (context, child, progress) {
//                                       if (progress == null) return child;
//                                       return Center(
//                                         child: CircularProgressIndicator(
//                                           value: progress.expectedTotalBytes != null
//                                               ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
//                                               : null,
//                                           color: isDark ? Colors.white : Colors.blue,
//                                         ),
//                                       );
//                                     },
//                                     errorBuilder: (context, error, stackTrace) {
//                                       return Center(
//                                         child: Icon(Icons.broken_image, color: Colors.grey, size: 40),
//                                       );
//                                     },
//                                   ),
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     );
//                   },
//                 ),
//
//               const SizedBox(height: 12),
//
//               Padding(
//                 padding: const EdgeInsets.only(left: 8),
//                 child: Row(
//                   children: [
//                     GestureDetector(
//                       onTap: () {
//                         Navigator.of(context).push(MaterialPageRoute(builder: (_) => ReactPopup(post: widget.post)));
//                       },
//                       child: Row(
//                         children: [
//                           Icon(Icons.thumb_up_alt_outlined, size: footerIconSize),
//                           SizedBox(width: 4),
//                           Text("$_reactCount", style: TextStyle(color: textColor, fontSize: footerTextSize))
//                         ],
//                       ),
//                     ),
//                     SizedBox(width: footerSpacing),
//                     GestureDetector(
//                       onTap: () {
//                         Navigator.of(context).push(MaterialPageRoute(
//                           builder: (_) => CommentPopup(
//                             post: widget.post,
//                             onCommentAdded: (newCount) {
//                               setState(() {
//                                 _commentCount  = newCount;
//                               });
//                             },
//                           ),
//                         ));
//                       },
//                       child: Row(
//                         children: [
//                           Icon(Icons.mode_comment_outlined, size: footerIconSize, color: secondaryText),
//                           SizedBox(width: 4),
//                           Text("$_commentCount", style: TextStyle(color: textColor, fontSize: footerTextSize)),
//                         ],
//                       ),
//                     ),
//
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Row(
//                 children: [
//                   for (int i = 0; i < _reactions.length; i++)
//                     GestureDetector(
//                       onTap: () => _handleReaction(i),
//                       child: Container(
//                         margin: EdgeInsets.only(right: reactionIconMargin),
//                         padding: EdgeInsets.all(reactionIconPadding),
//                         decoration: BoxDecoration(
//                           color: _selectedReaction == i ? _reactions[i]['color'].withOpacity(0.2) : Colors.transparent,
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Image.asset('assets/${_reactions[i]['asset']}', width: reactionIconSize, height: reactionIconSize),
//                       ),
//                     ),
//                   const Spacer(),
//
//                   // Share button
//                   Padding(
//                     padding: EdgeInsets.only(right: screenWidth > 400 ? 20 : 15),
//                     child: GestureDetector(
//                       onTap: () {
//                         print("Share post");
//                       },
//                       child: Icon(Icons.share, size: screenWidth > 400 ? 22 : 18, color: secondaryText),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   void _showFullImage(BuildContext context, String currentUrl) {
//     final currentIndex = widget.post.imageUrls.indexOf(currentUrl);
//     final PageController controller = PageController(initialPage: currentIndex);
//
//     showDialog(
//       context: context,
//       builder: (_) => Dialog(
//         backgroundColor: Colors.black,
//         insetPadding: EdgeInsets.zero,
//         child: PageView.builder(
//           controller: controller,
//           itemCount: widget.post.imageUrls.length,
//           itemBuilder: (context, index) {
//             final url = widget.post.imageUrls[index];
//             return GestureDetector(
//               onTap: () => Navigator.of(context).pop(),
//               child: InteractiveViewer(
//                 maxScale: 5.0,
//                 minScale: 1.0,
//                 child: Center(
//                   child: Image.network(
//                     url,
//                     fit: BoxFit.contain,
//                     loadingBuilder: (context, child, progress) {
//                       if (progress == null) return child;
//                       return const Center(child: CircularProgressIndicator(color: Colors.white));
//                     },
//                     errorBuilder: (context, error, stackTrace) {
//                       return const Center(
//                         child: Icon(Icons.broken_image, color: Colors.grey, size: 40),
//                       );
//                     },
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
//
// }
//
// enum ReactionType { Like, Love, Haha, Wow, Sad, Angry }
//
// extension ReactionTypeExtension on ReactionType {
//   String get name {
//     switch (this) {
//       case ReactionType.Like:
//         return "Like";
//       case ReactionType.Love:
//         return "Love";
//       case ReactionType.Haha:
//         return "Haha";
//       case ReactionType.Wow:
//         return "Wow";
//       case ReactionType.Sad:
//         return "Sad";
//       case ReactionType.Angry:
//         return "Angry";
//     }
//   }
// }
