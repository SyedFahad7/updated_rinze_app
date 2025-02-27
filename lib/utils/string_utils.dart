String capitalize(String text) {
  return text.split(' ').map((word) {
    if (word.isNotEmpty) {
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }
    return word;
  }).join(' ');
}

String truncateText(String text, int maxLength) {
  if (text.length > maxLength) {
    return '${text.substring(0, maxLength)}...';
  }
  return '$text...';
}

String splitString(String status) {
  return status.replaceAllMapped(
    RegExp(r'([a-z])([A-Z])'),
    (match) => '${match.group(1)} ${match.group(2)}',
  );
}

String formatStringToMultiline(String input) {
  // Split the string by both space and slash
  List<String> words = input.split(RegExp(r'[ /\n]'));

  if (words.length > 1) {
    // Get the first word
    String firstWord = words.first;

    // Combine the remaining words
    String remainingWords = words.sublist(1).join(' ');

    // Return the formatted string with a newline between the first word and the rest
    return '$firstWord\n$remainingWords';
  }
  return input; // Return the input if it's a single word or no slashes/spaces
}
