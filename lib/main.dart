import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_datastore/amplify_datastore.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:devdeme3/login.dart';
import 'package:devdeme3/models/Blog.dart';
import 'package:devdeme3/models/ModelProvider.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';

import 'amplifyconfiguration.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _configureAmplify();
  // await Amplify.DataStore.clear();
  runApp(const MyApp());
}

Future<void> _configureAmplify() async {
  try {
    final auth = AmplifyAuthCognito();
    final amplifyDatastore =
        AmplifyDataStore(modelProvider: ModelProvider.instance);
    final api = AmplifyAPI();
    await Amplify.addPlugins([auth, amplifyDatastore, api]);

    await Amplify.configure(amplifyconfig);
  } catch (e) {
    print("An error occured while configuring Amplify: $e");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SwitchPage(),
    );
  }
}

class SwitchPage extends StatefulWidget {
  const SwitchPage({super.key});

  @override
  State<SwitchPage> createState() => _SwitchPageState();
}

class _SwitchPageState extends State<SwitchPage> {
  AuthUser? user;

  Future<bool> isUserSignedIn() async {
    final result = await Amplify.Auth.fetchAuthSession();
    return result.isSignedIn;
  }

  Future<AuthUser> getCurrentUser() async {
    final user = await Amplify.Auth.getCurrentUser();
    return user;
  }

  void check(BuildContext context) async {
    if (await isUserSignedIn()) {
      user = await getCurrentUser();
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => BlogPage(
                    user: user!,
                  )));
    } else {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => LoginPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    check(context);
    return Scaffold(
      body: Column(children: [
        Center(
          child: CircularProgressIndicator(),
        )
      ]),
    );
  }
}

class BlogPage extends StatefulWidget {
  const BlogPage({
    required this.user,
    super.key,
  });
  final AuthUser user;

  @override
  State<BlogPage> createState() => _BlogPageState();
}

class _BlogPageState extends State<BlogPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("BLog Page"),
        actions: [
          
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 10,),
          Row(children: [Text("${widget.user.userId}")],),
          SizedBox(
            height: 10,
          ),
          ElevatedButton(
              onPressed: () {
                final word = generateWordPairs();
                final blog = Blog(name: word.first.first);
                Amplify.DataStore.save(blog);
              },
              child: const Text('Create blog')),
          const SizedBox(
            height: 20,
          ),
          StreamBuilder<QuerySnapshot<Blog>>(
              stream: Amplify.DataStore.observeQuery(Blog.classType),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox(
                    width: 70,
                    height: 70,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.data == null) {
                  return const Text("No blog added yet");
                }
                return Expanded(
                  child: ListView.builder(
                      itemCount: snapshot.data!.items.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          onTap: () {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => PostPage(
                            //       blog: snapshot.data!.items[index],
                            //     ),
                            //   ),
                            // );
                          },
                          title: Text(
                            snapshot.data!.items[index].name,
                          ),
                        );
                      }),
                );
              })
        ],
      ),
    );
  }
}

// class PostPage extends StatefulWidget {
//   const PostPage({required this.blog, super.key});
//   final Blog blog;

//   @override
//   State<PostPage> createState() => _PostPageState();
// }

// class _PostPageState extends State<PostPage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Post Page"),
//       ),
//       body: Column(
//         children: [
//           ElevatedButton(
//               onPressed: () {
//                 final word = generateWordPairs();
//                 final word2 = generateWordPairs();
//                 final post = Post(
//                   title: "${word.first.first}, ${word2.first.first}",
//                   blog: widget.blog,
//                 );
//                 Amplify.DataStore.save(post);
//               },
//               child: const Text('Create Post')),
//           const SizedBox(
//             height: 20,
//           ),
//           StreamBuilder<QuerySnapshot<Post>>(
//               stream: Amplify.DataStore.observeQuery(Post.classType,
//                   where: Post.BLOG.eq(widget.blog.id)),
//               builder: (context, snapshot) {
//                 if (!snapshot.hasData) {
//                   return const SizedBox(
//                     width: 70,
//                     height: 70,
//                     child: Center(child: CircularProgressIndicator()),
//                   );
//                 }

//                 if (snapshot.data == null) {
//                   return const Text("No post added yet");
//                 }
//                 return Expanded(
//                   child: ListView.builder(
//                       itemCount: snapshot.data!.items.length,
//                       itemBuilder: (context, index) {
//                         return ListTile(
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => CommentPage(
//                                     post: snapshot.data!.items[index],
//                                   ),
//                                 ),
//                               );
//                             },
//                             title: Text(
//                               snapshot.data!.items[index].title ?? "np",
//                             ),
//                             subtitle: StreamBuilder(
//                               stream: Amplify.DataStore.observeQuery(
//                                   Comment.classType,
//                                   where: Comment.POST
//                                       .eq(snapshot.data!.items[index].id)),
//                               builder: ((context, snapshot) {
//                                 if (!snapshot.hasData) return const Text("");
//                                 if (snapshot.data!.items.isEmpty) {
//                                   return const Text("");
//                                 }
//                                 return Text(
//                                     "${snapshot.data!.items.length} comments");
//                               }),
//                             ));
//                       }),
//                 );
//               })
//         ],
//       ),
//     );
//   }
// }

// class CommentPage extends StatefulWidget {
//   const CommentPage({required this.post, super.key});
//   final Post post;

//   @override
//   State<CommentPage> createState() => _CommentPageState();
// }

// class _CommentPageState extends State<CommentPage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Post comment')),
//       body: Column(children: [
//         ElevatedButton(
//           onPressed: () {
//             final words = generateWordPairs();

//             final comment = Comment(
//               content: words.toString(),
//               post: widget.post,
//             );
//             // widget.post.comments!.add(comment);
//             Amplify.DataStore.save(comment);
//             final newComment = widget.post.comments ?? <Comment>[];
//             newComment.add(comment);
//             widget.post.copyWith(comments: newComment);
//             Amplify.DataStore.save(widget.post);
//           },
//           child: const Text("Add comment to this post"),
//         ),
//         Row(
//           children: const [Text("Find all comments in this blog below")],
//         ),
//         const Divider(),
//         Expanded(
//           child: StreamBuilder<QuerySnapshot<Comment>>(
//               stream: Amplify.DataStore.observeQuery(Comment.classType,
//                   where: Comment.POST.eq(widget.post.id)),
//               builder: (context, snapshot) {
//                 if (!snapshot.hasData) {
//                   return const CircularProgressIndicator();
//                 }
//                 if (snapshot.data == null) {
//                   return const Text("No comment added yet");
//                 }
//                 return ListView.builder(
//                     itemCount: snapshot.data!.items.length,
//                     itemBuilder: (context, index) {
//                       return ListTile(
//                         onTap: () {
//                           // Navigator.push(context, MaterialPageRoute(builder: (context)=> ));
//                         },
//                         title: Text(
//                           snapshot.data!.items[index].content,
//                         ),
//                       );
//                     });
//               }),
//         )
//       ]),
//     );
//   }
// }
