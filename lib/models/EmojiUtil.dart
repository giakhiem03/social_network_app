class EmojiUtil {
  // Hàm này sẽ loại bỏ dấu ':' ở đầu và cuối chuỗi emoji
  static String? stripColons(String? emojiName) {
    if (emojiName != null && emojiName.startsWith(':') ) {
      return emojiName.substring(1);
    }
    return emojiName;
  }

  // Danh sách tên emoji hợp lệ
  static const List<String> validEmojiNames = [
    'smile', 'thumbs_up', 'heart', 'laughing', 'd', 'wink', 'cry', 'angry',
    'blush', 'sunglasses', 'thinking', 'clap', 'pray', 'fire', 'star',
    'rocket', 'ok_hand', 'wave', 'grinning', 'kiss', 'shushing_face',
    'zzz', 'eyes', 'monkey_face', 'skull', 'unicorn', 'rainbow',
  ];

  // Hàm kiểm tra xem tên emoji có hợp lệ hay không
  static bool hasName(String emojiName) {
    return validEmojiNames.contains(emojiName);
  }
  // Hàm lấy emoji từ tên
  static String? get(String emojiName) {
    return emojiMap[emojiName];
  }

  // Bản đồ tên emoji và ký tự emoji tương ứng
  static const Map<String, String> emojiMap = {
    'smile': '😊',
    'thumbs_up': '👍',
    'heart': '❤️',
    'laughing': '😂',
    'd': '😄',
    'wink': '😉',
    'cry': '😢',
    'angry': '😠',
    'blush': '😊',
    'sunglasses': '😎',
    'thinking': '🤔',
    'clap': '👏',
    'pray': '🙏',
    'fire': '🔥',
    'star': '⭐',
    'rocket': '🚀',
    'ok_hand': '👌',
    'wave': '👋',
    'grinning': '😀',
    'kiss': '😘',
    'shushing_face': '🤫',
    'zzz': '💤',
    'eyes': '👀',
    'monkey_face': '🐵',
    'skull': '💀',
    'unicorn': '🦄',
    'rainbow': '🌈',
    // Thêm các emoji khác tại đây
  };
}
