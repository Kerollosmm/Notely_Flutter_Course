
// Step 2: Create the EmailVerificationDialog as a separate widget
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_course_2/constants/padge_routs.dart';
import 'package:flutter_course_2/services/auth/Auth_servies.dart';

// ignore: must_be_immutable
class EmailVerificationDialog extends StatelessWidget {
  final user= AuthService.firebase().currentUser; 
  final String? Email;

   EmailVerificationDialog({super.key,this.Email});
  @override
  Widget build(BuildContext context) {
  
    return Dialog(
      backgroundColor: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
         const  SizedBox(height: 15,),
        const  Icon(
            Icons.circle,
            size: 50,
            color: Colors.black,
          ),
         const SizedBox(height: 5,width: 50,),
         const Icon(
            Icons.circle,
            size: 10,
            color: Colors.cyan,
          ),
        const  SizedBox(height: 20),
         const Text(
            'Please verify your email',
            style: TextStyle(color: Colors.black, fontSize: 18),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          Text(
            'We just sent an email to ${Email?? null}.\nClick the link in the email to verify your account.',
            style: TextStyle(color: Colors.grey[900], fontSize: 14),
            textAlign: TextAlign.center,
          ),
         const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding:const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                onPressed: ()async{
                  // Handle resend email
                  await AuthService.firebase().sendEmailVerification();
                },
                child:const Text('Resend email',style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  overlayColor: Colors.black,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                onPressed: () {
                Navigator.pushNamedAndRemoveUntil(context,loginRoute,(route) => false ); 
                },
                child: Text('Update email',style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),),
              ),
            ],
          ),
          const SizedBox(height: 15,),
        ],
      ),
    );
  }
}