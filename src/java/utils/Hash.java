package utils;

import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.Base64;

public class Hash {
  public static String sha256(String raw, String salt) {
    try {
      MessageDigest md = MessageDigest.getInstance("SHA-256");
      md.update(salt.getBytes());
      byte[] out = md.digest(raw.getBytes());
      return Base64.getEncoder().encodeToString(out) + ":" + salt;
    } catch (Exception e) {
      throw new RuntimeException(e);
    }
  }

  public static boolean verify(String raw, String stored) {
    if (stored == null || !stored.contains(":")) return false;
    String[] parts = stored.split(":", 2);
    String hashB64 = parts[0];
    String salt = parts[1];
    String recomputed = sha256(raw, salt);
    String recomputedHashB64 = recomputed.split(":",2)[0];
    return constantTimeEquals(hashB64, recomputedHashB64);
  }

  public static String randomSalt() {
    byte[] s = new byte[16];
    new SecureRandom().nextBytes(s);
    return Base64.getEncoder().encodeToString(s);
  }

  private static boolean constantTimeEquals(String a, String b) {
    if (a == null || b == null || a.length() != b.length()) return false;
    int r = 0;
    for (int i=0; i<a.length(); i++) r |= a.charAt(i) ^ b.charAt(i);
    return r == 0;
  }
}
