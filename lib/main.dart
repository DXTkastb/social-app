import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'app-state/app_state.dart';
import 'change_notifiers/app_state_notifier.dart';
import 'change_notifiers/timeline_posts_set_notifier.dart';
import 'change_notifiers/user_data_notifier.dart';
import 'change_notifiers/user_metadata_notifier.dart';
import 'change_notifiers/user_notifications_notifier.dart';
import 'change_notifiers/user_personal_posts_set_notifier.dart';
import 'change_notifiers/user_personal_story.dart';
import 'component_widgets/bottom_buttons.dart';
import 'component_widgets/normal_circular_indicator.dart';
import 'firebase_options.dart';
import 'rest-service/rest_client.dart';
import 'rsocket-engine/risolate_service/main_isolate_engine.dart';
import 'screens/material_appx.dart';
import 'shared-prefs/shared_pref_service.dart';

void updateUserFcmTokenOnServer() {}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    //  DeviceOrientation.portraitDown,
  ]);
  await SharedPrefService.init();
  RestClient.init();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await MainIsolateEngine.engine.engineStart();

  AppState aState = await AppState().getAppState();
  AppStateNotifier appState = AppStateNotifier(aState.user, aState.state);

  // await Future.delayed(const Duration(seconds: 1));

  runApp(RootApp(app_state: appState));
}

class RootApp extends StatelessWidget {
  final AppStateNotifier app_state;

  const RootApp({
    super.key,
    required this.app_state,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: app_state,
      child: const App(),
    );
  }
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateNotifier>(
      builder: (ctx, appStateNotifier, child) {
        var provider = appStateNotifier;
        if (provider.getState() == 1) {
          return FutureBuilder(
            key: Key('${appStateNotifier.refreshCounter}'),
              future: appStateNotifier.rConnect,
              builder: (futureContext, snapshot) {
                Widget widget;
                if (snapshot.connectionState == ConnectionState.done) {
                    widget = MultiProvider(
                      key : const Key('multi-data-providers'),
                      providers: [
                        ChangeNotifierProvider<UserNotificationsNotifier>(
                          create: (_) => UserNotificationsNotifier(
                              accountName: provider.user!.accountname)
                            ..init(),
                        ),
                        ChangeNotifierProvider<UserDataNotifier>(
                          create: (_) => UserDataNotifier(provider.user!),
                        ),
                        ChangeNotifierProvider<UserMetaDataNotifier>(
                            create: (_) {
                          return UserMetaDataNotifier(
                              accountName: provider.user!.accountname,
                              postsCount: provider.user!.postsCount,
                              followerCount: provider.user!.followerCount,
                              followingCount: provider.user!.followingCount)
                            ..init();
                        }),
                        ChangeNotifierProvider<TimelinePostsNotifier>(
                          create: (_) => TimelinePostsNotifier()
                            ..init(provider.user!.accountname),
                        ),
                        ChangeNotifierProvider<UserPersonalPostSet>(
                          create: (_) => UserPersonalPostSet()
                            ..init(provider.user!.accountname),
                        ),
                        ChangeNotifierProvider<UserPersonalStoryNotifier>(
                          create: (_) => UserPersonalStoryNotifier()
                            ..init(provider.user!.accountname),
                        ),
                      ],
                      child: const GlobalMaterialApp(),
                    );
                } else {
                  widget = const MaterialApp(
                    debugShowCheckedModeBanner: false,
                    key: Key('reload-rsocket'),
                    home: Scaffold(
                      key: Key('rsocket-error-page'),
                      backgroundColor: Colors.black,
                      body: Center(
                        child: NormalCircularIndicator(),
                      ),
                    ),
                  );
                }

                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: widget,
                  transitionBuilder: (wid, widAnimation) {
                    return FadeTransition(
                      opacity: widAnimation,
                      child: wid,
                    );
                  },
                );
              });
        } else {
          return MaterialAppX(routeNumber: provider.getState());
        }
      },
    );
  }
}

class GlobalMaterialApp extends StatelessWidget {
  const GlobalMaterialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialAppX(routeNumber: 1);
    // return MultiProvider(
    //   providers: [
    //     StreamProvider.value(
    //       initialData: 0,
    //       value: Provider.of<UserNotificationsNotifier>(context, listen: false)
    //           .notificationStream,
    //     ),
    //   ],
    //   child: const MaterialAppX(routeNumber: 1),
    // );
  }
}

/*

  @override
  Widget build(BuildContext context) {

    var provider = Provider.of<AppStateNotifier>(context, listen: false);
    return MultiProvider(
      providers: [
        ChangeNotifierProxyProvider<AppStateNotifier,
            UserNotificationsNotifier>(
          create: (_) => UserNotificationsNotifier(
              accountName: provider.user!.accountname)..init(),
          update: (_, asn, udn) {
            return UserNotificationsNotifier(
                accountName: provider.user!.accountname)..init();
          },
        ),
        // change to ChangeNotifierProxyProvider for fetching accountname for stream
        ChangeNotifierProxyProvider<AppStateNotifier, UserDataNotifier>(
          create: (_) => UserDataNotifier(provider.user!),
          update: (_, asn, udn) {
            return UserDataNotifier(asn.user!);
          },
        ),
        ChangeNotifierProxyProvider<AppStateNotifier, UserMetaDataNotifier>(
            create: (_) {
          return UserMetaDataNotifier(
              accountName: provider.user!.accountname,
              postsCount: provider.user!.postsCount,
              followerCount: provider.user!.followerCount,
              followingCount: provider.user!.followingCount)
            ..init();
        }, update: (_, asn, udn) {
          return UserMetaDataNotifier(
              accountName: asn.user!.accountname,
              postsCount:  asn.user!.postsCount,
              followerCount:  asn.user!.followerCount,
              followingCount:  asn.user!.followingCount)
            ..init();
        }),
        ChangeNotifierProxyProvider<AppStateNotifier, TimelinePostsNotifier>(
          create: (_) =>
              TimelinePostsNotifier()..init(provider.user!.accountname),
          update: (_, asn, tpn) {
            return TimelinePostsNotifier()..init(asn.user!.accountname);
          },
        ),
        ChangeNotifierProxyProvider<AppStateNotifier, UserPersonalPostSet>(
          create: (_) =>
              UserPersonalPostSet()..init(provider.user!.accountname),
          update: (_, asn, tpn) {
            return UserPersonalPostSet()..init(asn.user!.accountname);
          },
        ),
        ChangeNotifierProxyProvider<AppStateNotifier,
            UserPersonalStoryNotifier>(
          create: (_) =>
              UserPersonalStoryNotifier()..init(provider.user!.accountname),
          update: (_, asn, upsn) {
            return UserPersonalStoryNotifier()..init(asn.user!.accountname);
          },
        ),
      ],
      child: const GlobalMaterialApp(),
    );
  }

 */
