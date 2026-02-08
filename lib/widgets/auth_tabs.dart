import 'package:flutter/material.dart';
import 'package:talker_flutter/talker_flutter.dart';

class AuthTabsWidget extends StatefulWidget {
  const AuthTabsWidget({
    super.key,
    required this.onLogin,
    required this.onSignup,
  });

  final Function(String email, String password) onLogin;
  final Function(String nickname, String email, String password) onSignup;

  @override
  State<AuthTabsWidget> createState() => _AuthTabsWidgetState();
}

class _AuthTabsWidgetState extends State<AuthTabsWidget>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _isPasswordVisible = false;
  bool _isLogin = true;

  final _loginFormKey = GlobalKey<FormState>();
  final _signUpFormKey = GlobalKey<FormState>();

  String _enteredNickname = "";
  String _enteredPassword = "";
  String _enteredEmail = "";

  final talker = Talker();

  void _submit() {
    talker.info("${_tabController.index}");

    final form = _tabController.index == 0 ? _loginFormKey : _signUpFormKey;
    final isValid = form.currentState!.validate();

    if (!isValid) return talker.info("Form is not valid");
    form.currentState!.save();

    _tabController.index == 0
        ? widget.onLogin(_enteredEmail, _enteredPassword)
        : widget.onSignup(_enteredNickname, _enteredEmail, _enteredPassword);
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: const Color.fromARGB(255, 51, 65, 85),
              borderRadius: BorderRadius.circular(8),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: Color.fromARGB(255, 203, 213, 225),
            labelStyle: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
            dividerHeight: 0,
            tabs: const [
              Tab(text: "Login"),
              Tab(text: "Sign Up"),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TabBarView(
              controller: _tabController,
              children: [
                Column(
                  children: [
                    Form(
                      key: _loginFormKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 15),
                          Text(
                            "EMAIL ADDRESS",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Color.fromARGB(255, 107, 114, 128),
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: theme.colorScheme.onSurfaceVariant
                                  .withAlpha(127),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color.fromARGB(255, 51, 65, 85),
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color.fromARGB(255, 51, 65, 85),
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: theme.textTheme.bodyMedium?.color,
                              ),
                              hintText: "name@example.com",
                              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                                color: Color.fromARGB(255, 107, 114, 128),
                              ),
                            ),
                            autocorrect: false,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  !value.contains("@")) {
                                return "Please enter valid email address";
                              }

                              return null;
                            },
                            onSaved: (value) {
                              _enteredEmail = value!;
                            },
                          ),
                          const SizedBox(height: 15),
                          Text(
                            "PASSWORD",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            obscureText: !_isPasswordVisible,
                            obscuringCharacter: "*",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Color.fromARGB(255, 107, 114, 128),
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: theme.colorScheme.onSurfaceVariant
                                  .withAlpha(127),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color.fromARGB(255, 51, 65, 85),
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color.fromARGB(255, 51, 65, 85),
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: theme.textTheme.bodyMedium?.color,
                              ),
                              hintText: "**********",
                              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                                color: Color.fromARGB(255, 107, 114, 128),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: theme.textTheme.bodyMedium?.color,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                            ),
                            autocorrect: false,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  value.trim().length < 6) {
                                return "Please enter valid password";
                              }

                              return null;
                            },
                            onSaved: (value) {
                              _enteredPassword = value!;
                            },
                          ),
                          const SizedBox(height: 40),
                          Center(
                            child: Container(
                              width: double.infinity,
                              height: 70,
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.colorScheme.onPrimary
                                        .withAlpha(100),
                                    blurRadius: 30,
                                    spreadRadius: -8,
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor: WidgetStatePropertyAll(
                                    theme.colorScheme.onPrimary,
                                  ),
                                  shape: WidgetStatePropertyAll(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  _submit();
                                },
                                child: Text(
                                  "Login",
                                  style: theme.textTheme.titleLarge,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Form(
                      key: _signUpFormKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 15),
                          Text(
                            "NICKNAME",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Color.fromARGB(255, 107, 114, 128),
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: theme.colorScheme.onSurfaceVariant
                                  .withAlpha(127),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color.fromARGB(255, 51, 65, 85),
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color.fromARGB(255, 51, 65, 85),
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: Icon(
                                Icons.alternate_email_outlined,
                                color: theme.textTheme.bodyMedium?.color,
                              ),
                              hintText: "yourname",
                              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                                color: Color.fromARGB(255, 107, 114, 128),
                              ),
                            ),
                            autocorrect: false,
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  value.trim().length < 3) {
                                return "Please enter valid nickname";
                              }

                              return null;
                            },
                            onSaved: (value) {
                              _enteredNickname = value!;
                            },
                          ),
                          const SizedBox(height: 15),
                          Text(
                            "EMAIL ADDRESS",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Color.fromARGB(255, 107, 114, 128),
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: theme.colorScheme.onSurfaceVariant
                                  .withAlpha(127),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color.fromARGB(255, 51, 65, 85),
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color.fromARGB(255, 51, 65, 85),
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: theme.textTheme.bodyMedium?.color,
                              ),
                              hintText: "name@example.com",
                              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                                color: Color.fromARGB(255, 107, 114, 128),
                              ),
                            ),
                            autocorrect: false,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  !value.contains("@")) {
                                return "Please enter valid email address";
                              }

                              return null;
                            },
                            onSaved: (value) {
                              _enteredEmail = value!;
                            },
                          ),
                          const SizedBox(height: 15),
                          Text(
                            "PASSWORD",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            obscureText: !_isPasswordVisible,
                            obscuringCharacter: "*",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Color.fromARGB(255, 107, 114, 128),
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: theme.colorScheme.onSurfaceVariant
                                  .withAlpha(127),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color.fromARGB(255, 51, 65, 85),
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color.fromARGB(255, 51, 65, 85),
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: theme.textTheme.bodyMedium?.color,
                              ),
                              hintText: "**********",
                              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                                color: Color.fromARGB(255, 107, 114, 128),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: theme.textTheme.bodyMedium?.color,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                            ),
                            autocorrect: false,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  value.trim().length < 6) {
                                return "Please enter valid password";
                              }

                              return null;
                            },
                            onSaved: (value) {
                              _enteredPassword = value!;
                            },
                          ),
                          const SizedBox(height: 40),
                          Center(
                            child: Container(
                              width: double.infinity,
                              height: 70,
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.colorScheme.onPrimary
                                        .withAlpha(100),
                                    blurRadius: 30,
                                    spreadRadius: -8,
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor: WidgetStatePropertyAll(
                                    theme.colorScheme.onPrimary,
                                  ),
                                  shape: WidgetStatePropertyAll(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  _submit();
                                },
                                child: Text(
                                  "Sign Up",
                                  style: theme.textTheme.titleLarge,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
