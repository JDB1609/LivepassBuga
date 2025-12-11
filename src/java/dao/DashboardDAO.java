package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import utils.Conexion;
import utils.ChartPoint;

public class DashboardDAO {

    // Total de usuarios
    public int totalUsuarios() {
        int total = 0;
        String sql = "SELECT COUNT(*) FROM users";
        try (Connection  cn = new Conexion().getConnection();
             PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                total = rs.getInt(1);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return total;
    }

    // Total de organizadores
    public int totalOrganizadores() {
        int total = 0;
        String sql = "SELECT COUNT(*) FROM users WHERE role = 'ORGANIZADOR'";
        try (Connection cn = new Conexion().getConnection();
             PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                total = rs.getInt(1);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return total;
    }

    public int totalEventos() {
        int total = 0;
        String sql = "SELECT COUNT(*) FROM events";
        try (Connection cn = new Conexion().getConnection();
             PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                total = rs.getInt(1);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return total;
    }    
    
    public int totalTickets() {
        int total = 0;
        String sql = "SELECT SUM(qty) FROM tickets";
        try (Connection cn = new Conexion().getConnection();
             PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                total = rs.getInt(1);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return total;
    }
    
    public double totalComisiones() {
        double total = 0.0;
        String sql = "SELECT SUM(t.qty * tt.price) * 0.10 AS comision " +
                     "FROM tickets t " +
                     "JOIN ticket_types tt ON t.ticket_type_id = tt.id " +
                     "WHERE t.status = 'ACTIVO'";

        try (Connection cn = new Conexion().getConnection();
             PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                total = rs.getDouble("comision");
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return total;
    }
    
    public List<ChartPoint> ticketsPorDia(int dias) {

        List<ChartPoint> lista = new ArrayList<>();

        String sql = 
            "SELECT DATE(purchase_at) AS fecha, SUM(qty) AS total " +
            "FROM tickets " +
            "WHERE purchase_at >= DATE_SUB(CURDATE(), INTERVAL ? DAY) " +
            "GROUP BY DATE(purchase_at) " +
            "ORDER BY fecha ASC";

        try (Connection cn = new Conexion().getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setInt(1, dias);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                String fecha = rs.getString("fecha");
                int total = rs.getInt("total");

                lista.add(new ChartPoint(fecha, total));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return lista;
    }
    
    
    public List<ChartPoint> ticketsPorEvento() {

        List<ChartPoint> lista = new ArrayList<>();

        String sql =
            "SELECT e.title AS nombre, SUM(t.qty) AS total " +
            "FROM tickets t " +
            "JOIN events e ON e.id = t.event_id " +
            "GROUP BY e.title " +
            "ORDER BY total DESC";

        try (Connection cn = new Conexion().getConnection();
             PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                String nombre = rs.getString("nombre");
                int total = rs.getInt("total");

                lista.add(new ChartPoint(nombre, total));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return lista;
    }
}