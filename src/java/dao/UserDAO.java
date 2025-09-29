package dao;

import utils.Conexion;
import utils.User;
import utils.PasswordUtil;

import java.sql.*;
import java.util.Optional;

public class UserDAO {

    public Optional<User> findByEmail(String email) {
        String sql = "SELECT * FROM users WHERE email=?";
        Conexion cx = new Conexion();
        try (Connection cn = cx.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return Optional.of(map(rs));
            }
        } catch (Exception e) { throw new RuntimeException(e); }
        return Optional.empty();
    }

    public boolean emailExists(String email) {
        String sql = "SELECT 1 FROM users WHERE email=?";
        Conexion cx = new Conexion();
        try (Connection cn = cx.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) { return rs.next(); }
        } catch (Exception e) { throw new RuntimeException(e); }
    }

    public int create(String name, String email, String phone, String role, String plainPass) {
        String sql = "INSERT INTO users(name,email,phone,role,pass_hash) VALUES(?,?,?,?,?)";
        String hash = PasswordUtil.hash(plainPass);
        Conexion cx = new Conexion();
        try (Connection cn = cx.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, name);
            ps.setString(2, email);
            ps.setString(3, phone);
            ps.setString(4, (role!=null && role.equalsIgnoreCase("ORGANIZADOR")) ? "ORGANIZADOR" : "CLIENTE");
            ps.setString(5, hash);
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (Exception e) { throw new RuntimeException(e); }
        return 0;
    }

    public Optional<User> auth(String email, String plainPass) {
        Optional<User> opt = findByEmail(email);
        if (opt.isEmpty()) return Optional.empty();
        User u = opt.get();
        if (PasswordUtil.verify(plainPass, u.getPassHash())) return opt;
        return Optional.empty();
    }

    private User map(ResultSet rs) throws SQLException {
        User u = new User();
        u.setId(rs.getInt("id"));
        u.setName(rs.getString("name"));
        u.setEmail(rs.getString("email"));
        u.setPhone(rs.getString("phone"));
        u.setRole(rs.getString("role"));
        u.setPassHash(rs.getString("pass_hash"));
        return u;
    }
}
