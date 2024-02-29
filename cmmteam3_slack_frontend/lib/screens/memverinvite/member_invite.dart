import 'package:flutter/material.dart';
import 'package:flutter_frontend/componnets/Nav.dart';
import 'package:flutter_frontend/constants.dart';
import 'package:flutter_frontend/model/SessionStore.dart';
import 'package:flutter_frontend/screens/home/workspacehome.dart';
import 'package:flutter_frontend/services/memberinvite/MemberInvite.dart';

class MemberInvitation extends StatefulWidget {
  const MemberInvitation({Key? key}) : super(key: key);
  @override
  State<MemberInvitation> createState() => _MemberInvitationState();
}

class _MemberInvitationState extends State<MemberInvitation> {
  TextEditingController emailController = TextEditingController();
  String workSpaceName =
      SessionStore.sessionData!.mWorkspace!.workspaceName.toString();
  int channelLength = SessionStore.sessionData!.mChannels!.length.toInt();
  int? channelId;
  bool _isSendingEmail =
      false; // State variable to track if email is being sent
  Future<void> _submitEmail(
      String email, int channelId, BuildContext context) async {
    try {
      // Set _isSendingEmail to true before sending email
      setState(() {
        _isSendingEmail = true;
      });
      await MemberInviteService().memberInvite(email, channelId);
      // Navigate to home screen after successful invitation
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const WorkHome(),
        ),
      );
    } catch (e) {
      // Handle errors here
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to send invitation. Please try again later.'),
        backgroundColor: Colors.red,
      ));
    } finally {
      // Set _isSendingEmail to false after email sending is complete
      setState(() {
        _isSendingEmail = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Nav(),
              ),
            );
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text(
          'Member Invitation',
          style: TextStyle(color: Colors.blueGrey),
        ),
        actions: const <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: Icon(Icons.mail),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Invite to $workSpaceName',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: channelLength,
                itemBuilder: (context, index) {
                  return ListTile(
                    tileColor: SessionStore.sessionData!.mChannels![index].id ==
                            channelId
                        ? Colors.green
                        : Colors.white,
                    enableFeedback: true,
                    selected: SessionStore.sessionData!.mChannels![index].id ==
                        channelId,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    title: TextButton(
                      onPressed: () {
                        setState(() {
                          channelId =
                              SessionStore.sessionData!.mChannels![index].id!;
                        });
                      },
                      child: Text(
                        SessionStore.sessionData!.mChannels![index].channelName
                            .toString(),
                        style: const TextStyle(color: kPrimaryTextColor),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: emailController,
              textInputAction: TextInputAction.next,
              cursorColor: kPrimaryColor,
              decoration: const InputDecoration(
                hintText: "Invite with Email",
                prefixIcon: Padding(
                  padding: EdgeInsets.all(defaultPadding),
                  child: Icon(Icons.email),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Visibility(
              visible:
                  _isSendingEmail, // Show loading indicator if email is being sent
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  const SizedBox(height: 8.0),
                  Text('Sending email...'),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Check if email is already being sent
                if (!_isSendingEmail) {
                  // If not sending, initiate email sending process
                  _submitEmail(emailController.text, channelId!, context);
                }
              },
              child: Text('Invite'),
              style: ElevatedButton.styleFrom(
                primary: Colors.lightBlue,
              ),
            )
          ],
        ),
      ),
    );
  }
}
