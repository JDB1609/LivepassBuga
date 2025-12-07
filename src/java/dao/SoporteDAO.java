package dao;

import utils.SoporteMensaje;
import utils.SoporteMensaje.Estado;
import utils.Conexion;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import utils.Mail;

public class SoporteDAO {

    public boolean guardar(SoporteMensaje mensaje) {
        String sql = "INSERT INTO support(nombre,email,mensaje) VALUES (?,?,?)";
        try (Connection con = Conexion.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, mensaje.getNombre());
            ps.setString(2, mensaje.getEmail());
            ps.setString(3, mensaje.getMensaje());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            System.err.println("❌ ERROR en guardar(): " + e.getMessage());
            e.printStackTrace();  
            return false;
        }
    }

    public List<SoporteMensaje> listarTodos() {
        List<SoporteMensaje> lista = new ArrayList<>();
        String sql = "SELECT * FROM support ORDER BY id DESC";

        System.out.println("🔍 Ejecutando listarTodos()...");

        try (Connection con = Conexion.getConexion();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            System.out.println("✅ Conexión exitosa");

            int contador = 0;
            while (rs.next()) {
                contador++;
                SoporteMensaje s = new SoporteMensaje();

                s.setId(rs.getInt("id"));
                s.setNombre(rs.getString("nombre"));
                s.setEmail(rs.getString("email"));
                s.setMensaje(rs.getString("mensaje"));
                s.setRespuesta(rs.getString("respuesta"));

                String estadoDB = rs.getString("estado");
                if (estadoDB != null) {
                    try {
                        s.setEstado(Estado.valueOf(estadoDB.toUpperCase()));
                    } catch (IllegalArgumentException e) {
                        System.err.println("Estado desconocido: " + estadoDB);
                    }
                }

                // <-- NUEVO: traer fecha desde la BD
                s.setFecha(rs.getTimestamp("fecha"));

                lista.add(s);
            }

            System.out.println("📊 Total registros encontrados: " + contador);

        } catch (SQLException e) {
            System.err.println("❌ ERROR SQL en listarTodos(): " + e.getMessage());
            e.printStackTrace();
        } catch (Exception e) {
            System.err.println("❌ ERROR GENERAL en listarTodos(): " + e.getMessage());
            e.printStackTrace();
        }

        return lista;
    }

    public List<SoporteMensaje> listarPendientes() {
        List<SoporteMensaje> lista = new ArrayList<>();
        String sql = "SELECT * FROM support WHERE estado = 'PENDIENTE' ORDER BY id DESC";

        System.out.println("🔍 Ejecutando listarPendientes()...");

        try (Connection con = Conexion.getConexion();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            int contador = 0;
            while (rs.next()) {
                contador++;
                SoporteMensaje s = new SoporteMensaje();
                s.setId(rs.getInt("id"));
                s.setNombre(rs.getString("nombre"));
                s.setEmail(rs.getString("email"));
                s.setMensaje(rs.getString("mensaje"));
                s.setRespuesta(rs.getString("respuesta"));
                s.setEstado(Estado.valueOf(rs.getString("estado")));

                // <-- NUEVO: traer fecha desde la BD
                s.setFecha(rs.getTimestamp("fecha"));

                lista.add(s);
            }
            System.out.println("📊 Pendientes encontrados: " + contador);

        } catch (Exception e) {
            System.err.println("❌ ERROR en listarPendientes(): " + e.getMessage());
            e.printStackTrace();
        }

        return lista;
    }

    public List<SoporteMensaje> listarAtendidos() {
        List<SoporteMensaje> lista = new ArrayList<>();
        String sql = "SELECT * FROM support WHERE estado = 'ATENDIDA' ORDER BY id DESC";

        System.out.println("🔍 Ejecutando listarAtendidos()...");

        try (Connection con = Conexion.getConexion();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            int contador = 0;
            while (rs.next()) {
                contador++;
                SoporteMensaje s = new SoporteMensaje();
                s.setId(rs.getInt("id"));
                s.setNombre(rs.getString("nombre"));
                s.setEmail(rs.getString("email"));
                s.setMensaje(rs.getString("mensaje"));
                s.setRespuesta(rs.getString("respuesta"));
                s.setEstado(Estado.valueOf(rs.getString("estado")));

                // <-- NUEVO: traer fecha desde la BD
                s.setFecha(rs.getTimestamp("fecha"));

                lista.add(s);
            }
            System.out.println("📊 Atendidos encontrados: " + contador);

        } catch (Exception e) {
            System.err.println("❌ ERROR en listarAtendidos(): " + e.getMessage());
            e.printStackTrace();
        }

        return lista;
    }


    
    // Método responder modificado para enviar correo
    public boolean responder(int id, String respuesta) {
        String sql = "UPDATE support SET respuesta = ?, estado = 'ATENDIDA' WHERE id = ?";
        
        System.out.println("🔍 Ejecutando responder() | ID: " + id);
        
        Connection con = null;
        PreparedStatement ps = null;
        
        try {
            con = Conexion.getConexion();
            
            // 1. Primero obtener los datos del mensaje para el correo
            SoporteMensaje mensaje = obtenerPorId(id, con);
            if (mensaje == null) {
                System.err.println("❌ No se encontró el mensaje con ID: " + id);
                return false;
            }
            
            // 2. Actualizar la respuesta en la base de datos
            ps = con.prepareStatement(sql);
            ps.setString(1, respuesta);
            ps.setInt(2, id);
            int filasAfectadas = ps.executeUpdate();
            System.out.println("📊 Filas actualizadas: " + filasAfectadas);
            
            if (filasAfectadas > 0) {
                // 3. Enviar correo al usuario
                boolean correoEnviado = enviarCorreoRespuesta(mensaje, respuesta);
                
                if (correoEnviado) {
                    System.out.println("✅ Correo enviado exitosamente a: " + mensaje.getEmail());
                } else {
                    System.err.println("⚠️ Respuesta guardada pero correo no enviado");
                }
                
                return true;
            }
            
            return false;
            
        } catch (Exception e) {
            System.err.println("❌ ERROR en responder(): " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            // Cerrar recursos
            try { if (ps != null) ps.close(); } catch (Exception e) {}
            try { if (con != null) con.close(); } catch (Exception e) {}
        }
    }
    
    // Método auxiliar para obtener mensaje por ID
    private SoporteMensaje obtenerPorId(int id, Connection con) {
        String sql = "SELECT id, nombre, email, mensaje, fecha FROM support WHERE id = ?";
        
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                SoporteMensaje sm = new SoporteMensaje();
                sm.setId(rs.getInt("id"));
                sm.setNombre(rs.getString("nombre"));
                sm.setEmail(rs.getString("email"));
                sm.setMensaje(rs.getString("mensaje"));
                sm.setFecha(rs.getTimestamp("fecha"));
                return sm;
            }
        } catch (Exception e) {
            System.err.println("❌ ERROR en obtenerPorId(): " + e.getMessage());
        }
        return null;
    }
    
    // Método para enviar el correo de respuesta
    private boolean enviarCorreoRespuesta(SoporteMensaje mensaje, String respuesta) {
        try {
            // ⚠️ IMPORTANTE: Configura estos valores con tus datos reales
            String parametros[] = {
                "LivePass",            // Nombre del remitente
                "apimultiservicioslanovena@gmail.com",              // Tu correo Gmail
                "zgxhgckgcptgxffo",        // Contraseña de aplicación (NO la normal)
                "LivePass - Respuesta a SOlucitud de soporte", // Asunto
                construirMensajeEmail(mensaje, respuesta) // Cuerpo del mensaje
            };
            
            // Destinatario (el usuario que hizo la consulta)
            String destinatarios[] = { mensaje.getEmail() };
            
            // Enviar correo
            return Mail.enviar(parametros, destinatarios);
            
        } catch (Exception e) {
            System.err.println("❌ ERROR en enviarCorreoRespuesta(): " + e.getMessage());
            return false;
        }
    }
    
    // Construir el mensaje HTML del correo
    private String construirMensajeEmail(SoporteMensaje mensaje, String respuesta) {
        return "<html>"
                + "<body style='font-family: Arial, sans-serif; line-height: 1.6; color: #ffffff; background-color: #0A0C14; margin: 0; padding: 20px;'>"
                + "<div style='max-width: 600px; margin: 0 auto; background-color: #0A0C14; padding: 30px; border-radius: 15px;'>"

                // Logo centrado
                + "<div style='text-align: center; margin-bottom: 30px;'>"
                + "<img src='https://res.cloudinary.com/dp4utz5l5/image/upload/v1764970216/Livepass_Buga_Logo_qnfqte.png' alt='Livepass Buga Logo' style='max-width: 250px; height: auto;'>"
                + "</div>"

                // Encabezado
                + "<h2 style='color: #00E0C6; text-align: center; margin-bottom: 25px;'>Respuesta a tu consulta de soporte</h2>"

                // Saludo
                + "<p style='color: #ffffff; font-size: 16px;'>Hola <strong style='color: #00E0C6;'>" + mensaje.getNombre() + "</strong>,</p>"
                + "<p style='color: #ffffff;'>Hemos recibido tu consulta y te respondemos a continuación:</p>"

                // Consulta del usuario (tarjeta gris)
                + "<div style='background-color: #262B39; padding: 20px; border-radius: 10px; margin: 20px 0; border-left: 4px solid #00E0C6;'>"
                + "<p style='color: #ffffff; margin: 0;'><strong style='color: #00E0C6;'>Tu consulta:</strong><br>" + mensaje.getMensaje() + "</p>"
                + "</div>"

                // Respuesta (tarjeta gris)
                + "<div style='background-color: #262B39; padding: 20px; border-radius: 10px; margin: 25px 0; border-left: 4px solid #6254D5;'>"
                + "<p style='color: #ffffff; margin: 0;'><strong style='color: #6254D5;'>Nuestra respuesta:</strong><br>" + respuesta + "</p>"
                + "</div>"

                // Mensaje final
                + "<p style='color: #ffffff;'>Si necesitas más ayuda, no dudes en contactarnos nuevamente.</p>"

                // Separador
                + "<hr style='border: none; border-top: 1px solid #262B39; margin: 30px 0;'>"

                // Pie de página
                + "<div style='text-align: center;'>"
                + "<p style='font-size: 12px; color: #888;'>"
                + "Este es un mensaje automático, por favor no responder a este correo.<br>"
                + "ID de consulta: <span style='color: #00E0C6;'>" + mensaje.getId() + "</span>"
                + "</p>"
                + "</div>"

                + "</div>"
                + "</body>"
                + "</html>";
    }
}