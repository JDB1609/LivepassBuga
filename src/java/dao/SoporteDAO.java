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
                "Soporte Tienda Online",            // Nombre del remitente
                "tucorreo@gmail.com",              // Tu correo Gmail
                "tu_contraseña_aplicacion",        // Contraseña de aplicación (NO la normal)
                "Respuesta a tu consulta de soporte", // Asunto
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
                + "<body style='font-family: Arial, sans-serif; line-height: 1.6; color: #333;'>"
                + "<div style='max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #ddd; border-radius: 10px;'>"
                + "<h2 style='color: #4CAF50;'>Respuesta a tu consulta de soporte</h2>"
                + "<p>Hola <strong>" + mensaje.getNombre() + "</strong>,</p>"
                + "<p>Hemos recibido tu consulta y te respondemos a continuación:</p>"
                + "<div style='background-color: #f9f9f9; padding: 15px; border-left: 4px solid #4CAF50; margin: 15px 0;'>"
                + "<p><strong>Tu consulta:</strong><br>" + mensaje.getMensaje() + "</p>"
                + "</div>"
                + "<div style='background-color: #e8f5e9; padding: 15px; border-left: 4px solid #2196F3; margin: 15px 0;'>"
                + "<p><strong>Nuestra respuesta:</strong><br>" + respuesta + "</p>"
                + "</div>"
                + "<p>Si necesitas más ayuda, no dudes en contactarnos nuevamente.</p>"
                + "<hr style='border: none; border-top: 1px solid #eee; margin: 20px 0;'>"
                + "<p style='font-size: 12px; color: #777;'>"
                + "Este es un mensaje automático, por favor no responder a este correo.<br>"
                + "ID de consulta: " + mensaje.getId()
                + "</p>"
                + "</div>"
                + "</body>"
                + "</html>";
    }
}