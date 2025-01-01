class CheckURL {
  static bool isValidUrl(String content) {
    try {
      final uri = Uri.parse(content);
      // Kiểm tra nếu có scheme (http hoặc https) và host hợp lệ
      return uri.hasScheme && uri.hasAuthority;
    } catch (e) {
      return false; // Nếu `Uri.parse` ném lỗi, thì không phải URL
    }
  }
}