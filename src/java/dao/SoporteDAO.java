package dao;

import utils.SoporteMensaje;
import utils.Conexion;  
import java.sql.*;

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
        e.printStackTrace();  // 👈 importante para ver el error real en consola
        return false;
    }

    }
}
