// import 'package:flutter/material.dart';
// import '../../../../data/services/webrtc_controller.dart';
//
// class ParticipantControlsDialog extends StatefulWidget {
//   final Participant participant;
//   final bool initialMicEnabled;
//   final bool initialCamEnabled;
//
//   const ParticipantControlsDialog({
//     super.key,
//     required this.participant,
//     this.initialMicEnabled = true,
//     this.initialCamEnabled = false,
//   });
//
//   @override
//   State<ParticipantControlsDialog> createState() => _ParticipantControlsDialogState();
// }
//
// class _ParticipantControlsDialogState extends State<ParticipantControlsDialog> {
//   late bool micEnabled;
//   late bool camEnabled;
//
//   @override
//   void initState() {
//     super.initState();
//     micEnabled = widget.initialMicEnabled;
//     camEnabled = widget.initialCamEnabled;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       title: Text("Controls for ${widget.participant.name}"),
//       content: SizedBox(
//         width: 200,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // --- Mic row ---
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   children: const [
//                     Icon(Icons.mic, color: Colors.black87),
//                     SizedBox(width: 8),
//                     Text("Mic"),
//                   ],
//                 ),
//                 Switch(
//                   value: micEnabled,
//                   onChanged: (v) => setState(() => micEnabled = v),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             // --- Cam row ---
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   children: const [
//                     Icon(Icons.videocam, color: Colors.black87),
//                     SizedBox(width: 8),
//                     Text("Camera"),
//                   ],
//                 ),
//                 Switch(
//                   value: camEnabled,
//                   onChanged: (v) => setState(() => camEnabled = v),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () {
//             Navigator.pop(context, {
//               'mic': micEnabled,
//               'cam': camEnabled,
//             });
//           },
//           child: const Text("Apply"),
//         ),
//         TextButton(
//           onPressed: () => Navigator.pop(context),
//           child: const Text("Close"),
//         ),
//       ],
//     );
//   }
// }
