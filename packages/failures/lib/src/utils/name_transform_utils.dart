String camelToSentence(String name) {
  return name.replaceAllMapped(RegExp(r'^([a-z])|[A-Z]'),
    (Match m) => m[1] == null ? ' ${m[0]}' : m[1]!.toUpperCase()
  );
}
