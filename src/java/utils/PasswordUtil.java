package utils;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.Base64;

public class PasswordUtil {
    private static final SecureRandom RNG = new SecureRandom();

    public static String hash(String plain) {
        byte[] salt = new byte[16];
        RNG.nextBytes(salt);
        byte[] digest = sha256(salt, plain.getBytes(StandardCharsets.UTF_8));
        return Base64.getEncoder().encodeToString(salt) + ":" +
               Base64.getEncoder().encodeToString(digest);
    }

    public static boolean verify(String plain, String stored) {
        if (stored == null || !stored.contains(":")) return false;
        String[] parts = stored.split(":");
        byte[] salt   = Base64.getDecoder().decode(parts[0]);
        byte[] target = Base64.getDecoder().decode(parts[1]);
        byte[] digest = sha256(salt, plain.getBytes(StandardCharsets.UTF_8));
        if (digest.length != target.length) return false;
        int r = 0;
        for (int i=0;i<digest.length;i++) r |= (digest[i] ^ target[i]);
        return r == 0;
    }

    private static byte[] sha256(byte[] salt, byte[] data) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            md.update(salt);
            return md.digest(data);
        } catch (Exception e) {
            throw new RuntimeException("SHA-256 no disponible", e);
        }
    }
}
