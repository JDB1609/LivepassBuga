<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="utils.Conexion, utils.Hash" %>
<%
  String nombre = (String) request.getParameter("nombre");
  String email  = (String) request.getParameter("email");
  String tel    = (String) request.getParameter("telefono");
  String pass   = (String) request.getParameter("pass");

  try (Connection cn = Conexion.getConnection()) {
    // Verificar si el email ya existe
    try (PreparedStatement ps = cn.prepareStatement("SELECT 1 FROM users WHERE email=?")) {
      ps.setString(1, email);
      try (ResultSet rs = ps.executeQuery()) {
        if (rs.next()) {
          request.setAttribute("signup_ok", "0");
          request.setAttribute("signup_error", "El email ya está registrado.");
          return;
        }
      }
    }

    String salt = Hash.randomSalt();
    String passHash = Hash.sha256(pass, salt);

    try (PreparedStatement ps = cn.prepareStatement(
      "INSERT INTO users (nombre, email, telefono, pass_hash, rol) VALUES (?,?,?,?,?)")) {
      ps.setString(1, nombre);
      ps.setString(2, email);
      ps.setString(3, tel);
      ps.setString(4, passHash);
      ps.setString(5, "user");
      int rows = ps.executeUpdate();
      request.setAttribute("signup_ok", rows > 0 ? "1" : "0");
      if (rows == 0) request.setAttribute("signup_error","No se insertó el usuario.");
    }
  } catch (Exception e) {
    request.setAttribute("signup_ok", "0");
    request.setAttribute("signup_error", "Error de servidor: " + e.getMessage());
  }
%>
