package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import utils.Conexion;

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
}