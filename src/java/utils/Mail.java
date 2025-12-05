package utils;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.util.Properties;
import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.Multipart;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeBodyPart;
import javax.mail.internet.MimeMessage;
import javax.mail.internet.MimeMultipart;

public class Mail {
    
    public static boolean enviar(String parametros[], String correosDestinatarios[]) {
        try {
            // 1) Configurar propiedades de la conexión
            Properties props = new Properties();
            props.setProperty("mail.smtp.host", "smtp.gmail.com");
            props.setProperty("mail.smtp.starttls.enable", "true");
            props.setProperty("mail.smtp.ssl.trust", "smtp.gmail.com");
            props.setProperty("mail.smtp.ssl.protocols", "TLSv1.2");
            props.setProperty("mail.smtp.port", "587");
            props.setProperty("mail.smtp.user", parametros[1]); // correoRemitente
            props.setProperty("mail.smtp.auth", "true");

            // Preparar la sesión
            Session session = Session.getDefaultInstance(props);

            // Construir el mensaje
            MimeMessage mm = new MimeMessage(session);
            mm.setFrom(new InternetAddress(parametros[1], parametros[0])); // correoRemitente y nombre
            
            // Configurar destinatarios
            InternetAddress toList[] = new InternetAddress[correosDestinatarios.length];
            for (int i = 0; i < correosDestinatarios.length; i++) {
                toList[i] = new InternetAddress(correosDestinatarios[i]);
            }
            mm.addRecipients(Message.RecipientType.TO, toList);
            
            mm.setSubject(parametros[3]); // asunto
            
            // 2) Crear el contenido del mensaje
            MimeBodyPart mimeMensaje = new MimeBodyPart();
            mimeMensaje.setContent(parametros[4], "text/html; charset=utf-8");
            
            Multipart mp = new MimeMultipart();
            mp.addBodyPart(mimeMensaje);
            mm.setContent(mp);
            
            // 3) Enviar el mensaje
            Transport t = session.getTransport("smtp");
            t.connect(parametros[1], parametros[2]); // correo y contraseña
            t.sendMessage(mm, mm.getAllRecipients());
            t.close();
            
            System.out.println("✅ Correo enviado exitosamente a: " + String.join(", ", correosDestinatarios));
            return true;
            
        } catch (UnsupportedEncodingException | MessagingException e) {
            System.err.println("❌ Error enviando correo: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    // Método sobrecargado para adjuntar archivos (opcional)
    public static boolean enviar(String parametros[], String correosDestinatarios[], String archivos[]) {
        try {
            // (Código similar pero con adjuntos - igual que en tu ejemplo)
            // ... puedes implementarlo si necesitas adjuntos
            return true;
        } catch (Exception e) {
            System.err.println("❌ Error enviando correo con adjuntos: " + e.getMessage());
            return false;
        }
    }
}
