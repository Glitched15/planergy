import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:supabase/supabase.dart';

import 'constraints.dart';
import 'controllers/main_controller.dart';
import 'main.dart';
import 'signup.dart';
import 'widgets.dart';

class Loginpage extends StatefulWidget {
  Loginpage({Key? key}) : super(key: key);

  @override
  _LoginpageState createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {
  MainController c = Get.put(MainController());
  final formkey = GlobalKey<FormState>();
  final client = SupabaseClient(sbemail, sbauth);
  bool invalid = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgcolor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: double.infinity,
            child: Form(
              key: formkey,
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(),
                    SvgPicture.asset(
                      'assets/logo.svg',
                      color: Colors.white,
                    ),
                    BText(
                      t: 'WELCOME.',
                      s: 32,
                      c: Colors.white,
                      w: FontWeight.bold,
                    ),
                    BText(
                      t: 'Hello there, login to see stories from\naround the civilisation.',
                      s: 14,
                      c: Colors.white,
                      w: FontWeight.bold,
                    ),
                    const Spacer(),
                    BText(
                      t: 'Email:',
                      s: 18,
                      c: Color(0xff979797),
                      w: FontWeight.bold,
                    ),
                    TextFormField(
                      decoration:
                          const InputDecoration(hintText: 'Enter Email'),
                      style: const TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                      ),
                      cursorColor: Colors.white,
                      keyboardType: TextInputType.emailAddress,
                      validator: (String? val) {
                        if (val!.isEmpty) {
                          return "Email is required";
                        }
                        if (!RegExp(
                                r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                            .hasMatch(val)) {
                          return 'Please enter a valid email address';
                        }
                        if (invalid) {
                          // invalid = false;
                          return "Invalid email or password";
                        }
                        return null;
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      onSaved: (String? value) {
                        c.email.value = value.toString();
                      },
                    ),
                    const Spacer(),
                    BText(
                      t: 'Password:',
                      s: 18,
                      c: Color(0xff979797),
                      w: FontWeight.bold,
                    ),
                    TextFormField(
                      decoration:
                          const InputDecoration(hintText: 'Enter Password'),
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                      ),
                      cursorColor: Colors.white,
                      obscureText: true,
                      validator: (String? val) {
                        if (val!.isEmpty) {
                          return "Password is required";
                        }
                        if (val.length <= 7) {
                          return "Use 8 or more characters";
                        }
                        if (invalid) {
                          invalid = false;
                          return "Invalid email or password";
                        }
                        return null;
                      },
                      onSaved: (String? value) {
                        c.password.value = value.toString();
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                    const Spacer(),
                    Container(
                      width: double.infinity,
                      color: pcolor,
                      child: TextButton(
                        onPressed: () async {
                          formkey.currentState!.save();
                          if (!formkey.currentState!.validate()) {
                            return;
                          }
                          formkey.currentState!.save();

                          final res = await client.auth.signIn(
                              email: c.email.value, password: c.password.value);

                          // print(res.error!.message);
                          if (res.error == null) {
                            c.userid = res.data!.user!.id;
                            final res2 = await client
                                .from('users')
                                .select()
                                .match({'userid': c.userid}).execute();
                            c.userdata = res2.data;

                            final cart = c.userdata[0]['cart'];

                            for (var i in cart.keys) {
                              if (cart[i] != "0") {
                                c.cartitems.add(i.toString());
                                c.totalprice += int.parse(
                                        c.userdata[0]['cart'][i].toString()) *
                                    c.getitembyname(i.toString())!.cost;
                              }
                            }
                            // print(c.cartitems);
                            c.cartitemslist = c.cartitems.toList();
                            c.totalmoney.value = int.parse(c.userdata[0]['money'].toString());

                            Get.to(() => HomeScreen());
                          } else if (res.error!.message ==
                                  'Invalid email or password' ||
                              res.error!.message ==
                                  'Invalid login credentials') {
                            setState(() {
                              invalid = true;
                            });
                          }
                        },
                        child: BText(t: 'SignIn', s: 22, c: Colors.white),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        BText(
                          t: "Don't have an account?",
                          s: 14,
                          c: Color(0xff7A869A),
                        ),
                        TextButton(
                          onPressed: () {
                            Get.to(SignupPage());
                          },
                          child: BText(
                            t: 'SignUp',
                            s: 14,
                            c: Color(0xff0041C4),
                          ),
                        )
                      ],
                    ),
                    const Spacer(flex: 3),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
