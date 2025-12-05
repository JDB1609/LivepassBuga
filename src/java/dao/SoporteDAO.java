package dao;

import utils.SoporteMensaje;
import utils.SoporteMensaje.Estado;
import utils.Conexion;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

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

    public boolean responder(int id, String respuesta) {
        String sql = "UPDATE support SET respuesta = ?, estado = 'ATENDIDA' WHERE id = ?";
        
        System.out.println("🔍 Ejecutando responder() | ID: " + id);

        try (Connection con = Conexion.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, respuesta);
            ps.setInt(2, id);

            int filasAfectadas = ps.executeUpdate();
            System.out.println("📊 Filas actualizadas: " + filasAfectadas);
            
            return filasAfectadas > 0;

        } catch (Exception e) {
            System.err.println("❌ ERROR en responder(): " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
}