import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled/blocs/user_list/user_list_bloc.dart';

import 'classes/user_tile.dart';
import 'custom_text_fields.dart';
import 'models/user.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (context) => UserListBloc())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Map<int, TextEditingController> nameControllers = {};
  final Map<int, TextEditingController> emailControllers = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text("Flutter Bloc"),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            final state = context.read<UserListBloc>().state;
            final id = state.users.length + 1;
            showBottomSheet(
              context: context,
              isNewUser: true, // Set the flag to indicate a new user
              id: id,
              nameController: TextEditingController(),
              emailController: TextEditingController(),
              onUpdatePressed: (nameController, emailController) {
                final user = User(
                  id: id,
                  name: nameController.text,
                  email: emailController.text,
                );
                context.read<UserListBloc>().add(AddUser(user: user));
                Navigator.pop(context);
              },
            );
          },
          child: const Center(
            child: Icon(Icons.add),
          ),
        ),
        body: BlocBuilder<UserListBloc, UserListState>(
          builder: (BuildContext context, state) {
            final users = state.users;
            if (state is UserListUpdated && state.users.isNotEmpty) {
              return SizedBox(
                height: MediaQuery.of(context).size.height - kToolbarHeight - kBottomNavigationBarHeight,
                child: ListView.builder(
                  itemCount: state.users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return buildUserTile(context, user);
                  },
                ),
              );
            } else {
              return const Center(
                child: Text('Users Not found'),
              );
            }
          },
        ));
  }

  Widget buildUserTile(BuildContext context, User user) {
    TextEditingController nameController = nameControllers[user.id] ?? TextEditingController(text: user.name);
    TextEditingController emailController = emailControllers[user.id] ?? TextEditingController(text: user.email);
    bool isNewUser = nameController.text.isEmpty && emailController.text.isEmpty;
    // Store the TextEditingController instances
    nameControllers[user.id] = nameController;
    emailControllers[user.id] = emailController;
    return UserListItem(
      user: user,
      nameController: nameController,
      emailController: emailController,
      onEditPressed: () {
        showBottomSheet(
          context: context,
          isNewUser: isNewUser,
          id: user.id,
          nameController: nameController,
          emailController: emailController,
          onUpdatePressed: (nameController, emailController) {
            final updatedUser = User(
              id: user.id,
              name: nameController.text,
              email: emailController.text,
            );
            context.read<UserListBloc>().add(UpdateUser(user: updatedUser));
            Navigator.pop(context);
          },
        );
      },
      onDeletePressed: () {
        context.read<UserListBloc>().add(DeleteUser(user: user));
      },
    );
  }



  Future showBottomSheet({
    required BuildContext context,
    required bool isNewUser,
    required int id,
    required TextEditingController nameController,
    required TextEditingController emailController,
    required void Function(TextEditingController, TextEditingController) onUpdatePressed,
  }) {
    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16.0),
        ),
      ),
      builder: (context) {
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus(); // Dismiss the keyboard
          },
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16.0,
                right: 16.0,
                top: 24.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isNewUser ? 'Add User': 'Edit User',
                    style: const TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  CustomTextField(
                    controller: nameController,
                    label: 'Name',
                    icon: Icons.person,
                  ),
                  const SizedBox(height: 16.0),
                  CustomTextField(
                    controller: emailController,
                    label: 'Email',
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 24.0),
                  ElevatedButton(
                    onPressed: () => onUpdatePressed(nameController, emailController),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white70,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      minimumSize: const Size(double.infinity, 48.0),
                    ),
                    child: Text(
                      isNewUser ? 'Add':'Update',
                      style: const TextStyle(fontSize: 16.0),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
