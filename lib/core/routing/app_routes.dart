/// Every route path in one place. Navigate with these, never with a string
/// literal:  context.go(AppRoutes.home)  /  context.push(AppRoutes.memory(id))
abstract final class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String signUp = '/signup';

  static const String home = '/home';
  static const String profile = '/profile';

  static const String memoryNew = '/memories/new';
  static const String memoryDetailPattern = '/memories/:id';
  static String memory(String id) => '/memories/$id';

  // In the design, not built yet (ComingSoonScreen).
  static const String map = '/map';
  static const String collections = '/collections';
  static const String timeline = '/timeline';
  static const String search = '/search';
}
