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

    // Crear un nuevo administrador
    public int create(String name, String email, String phone, String plainPass) {
        String sql = "INSERT INTO administrator (name, email, phone, pass_hash, created_at) VALUES (?, ?, ?, ?, NOW())";
        String hash = PasswordUtil.hash(plainPass);
        Conexion cx = new Conexion();

        try (Connection cn = cx.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, name);
            ps.setString(2, email);
            ps.setString(3, phone);
            ps.setString(4, hash);
            ps.executeUpdate();

            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) return rs.getInt(1);
            }

        } catch (Exception e) {
            throw new RuntimeException("Error creando administrador: " + e.getMessage(), e);
        }
        return 0;
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
        return a;
    }
}