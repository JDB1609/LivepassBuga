package LoginTest;

import org.junit.Test;
import static org.junit.Assert.*;

import java.net.HttpURLConnection;
import java.net.URL;
import java.io.OutputStream;
import java.io.InputStream;
import java.util.Scanner;

public class LoginTest {

    private final String LOGIN_URL =
        "http://localhost:8080/LivepassPagina/Control/ct_login.jsp";

    // ✅ LOGIN CORRECTO (cliente u organizador)
    @Test
    public void testLoginCorrecto() throws Exception {

        String params =
            "email=luis@gmail.com&pass=12345678";

        HttpURLConnection conn =
            (HttpURLConnection) new URL(LOGIN_URL).openConnection();

        conn.setRequestMethod("POST");
        conn.setDoOutput(true);
        conn.setRequestProperty(
            "Content-Type",
            "application/x-www-form-urlencoded"
        );

        try (OutputStream os = conn.getOutputStream()) {
            os.write(params.getBytes("UTF-8"));
        }

        int responseCode = conn.getResponseCode();
        assertEquals(200, responseCode);
    }

    // ❌ LOGIN CON CORREO INCORRECTO
    @Test
    public void testLoginCorreoIncorrecto() throws Exception {

        String params =
            "email=correo@invalido.com&pass=12345678";

        HttpURLConnection conn =
            (HttpURLConnection) new URL(LOGIN_URL).openConnection();

        conn.setRequestMethod("POST");
        conn.setDoOutput(true);
        conn.setRequestProperty(
            "Content-Type",
            "application/x-www-form-urlencoded"
        );

        try (OutputStream os = conn.getOutputStream()) {
            os.write(params.getBytes("UTF-8"));
        }

        String response = leerRespuesta(conn);
        assertTrue(
            response.toLowerCase().contains("error")
            || response.toLowerCase().contains("incorrect")
        );
    }

    // ❌ LOGIN CON CONTRASEÑA INCORRECTA
    @Test
    public void testLoginPasswordIncorrecta() throws Exception {

        String params =
            "email=luis@gmail.com&pass=mal123";

        HttpURLConnection conn =
            (HttpURLConnection) new URL(LOGIN_URL).openConnection();

        conn.setRequestMethod("POST");
        conn.setDoOutput(true);
        conn.setRequestProperty(
            "Content-Type",
            "application/x-www-form-urlencoded"
        );

        try (OutputStream os = conn.getOutputStream()) {
            os.write(params.getBytes("UTF-8"));
        }

        String response = leerRespuesta(conn);
        assertTrue(
            response.toLowerCase().contains("error")
            || response.toLowerCase().contains("incorrect")
        );
    }

    // 🔧 Método auxiliar
    private String leerRespuesta(HttpURLConnection conn)
            throws Exception {

        InputStream is = conn.getInputStream();
        Scanner sc = new Scanner(is, "UTF-8");
        StringBuilder sb = new StringBuilder();

        while (sc.hasNextLine()) {
            sb.append(sc.nextLine());
        }
        sc.close();

        return sb.toString();
    }
}
