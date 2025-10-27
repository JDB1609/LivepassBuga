package dao;

import utils.Conexion;
import utils.PasswordUtil;
import utils.Administrador;

import java.sql.*;
import java.util.Optional;

public class AdministradorDAO {

    // Buscar administrador por email
    public Optional<Administrador> findByEmail(String email) {
        String sql = "SELECT * FROM administrator WHERE email = ?";
        Conexion cx = new Conexion();

        try (Connection cn = cx.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return Optional.of(map(rs));
            }

        } catch (Exception e) {
            throw new RuntimeException("Error buscando administrador: " + e.getMessage(), e);
        }
        return Optional.empty();
    }

    // Autenticación del administrador
    public Optional<Administrador> auth(String email, String plainPass) {
        Optional<Administrador> opt = findByEmail(email);
        if (opt.isEmpty()) return Optional.empty();

        Administrador adm = opt.get();
        if (PasswordUtil.verify(plainPass, adm.getPassHash()))
            return opt;
        return Optional.empty();
    }

    // Crear un nuevo administrador (id = cédula)
    public boolean create(int id, String name, String email, String phone, String plainPass, Administrador.Status status) {
        String sql = "INSERT INTO administrator (id, name, email, phone, pass_hash, created_at, status) " +
                     "VALUES (?, ?, ?, ?, ?, NOW(), ?)";
        String hash = PasswordUtil.hash(plainPass);
        Conexion cx = new Conexion();

        try (Connection cn = cx.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setInt(1, id);
            ps.setString(2, name);
            ps.setString(3, email);
            ps.setString(4, phone);
            ps.setString(5, hash);
            ps.setString(6, status.name());  // guarda "ACTIVO" o "INACTIVO"

            int rows = ps.executeUpdate();
            return rows > 0;

        } catch (Exception e) {
            throw new RuntimeException("Error creando administrador: " + e.getMessage(), e);
        }
    }

    // Mapeo del ResultSet → Objeto Administrador
    private Administrador map(ResultSet rs) throws SQLException {
        Administrador a = new Administrador();
        a.setId(rs.getInt("id"));
        a.setName(rs.getString("name"));
        a.setEmail(rs.getString("email"));
        a.setPhone(rs.getString("phone"));
        a.setPassHash(rs.getString("pass_hash"));
        a.setCreatedAt(rs.getTimestamp("created_at"));
        String statusStr = rs.getString("status");
        if (statusStr != null)
            a.setStatus(Administrador.Status.valueOf(statusStr.toUpperCase()));
        return a;
    }
}