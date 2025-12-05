package dao;

import utils.SoporteMensaje;
import utils.Conexion;
import java.sql.Connection;
import java.sql.PreparedStatement;

public class SoporteDAO {

    public boolean guardar(SoporteMensaje mensaje) {

        String sql = "INSERT INTO support(nombre,email,mensaje) VALUES (?,?,?)";

        Conexion cx = new Conexion();

        try {
            // Aseguramos conexión
            if (!cx.estaConectado()) {
                System.err.println("[SoporteDAO] No se pudo conectar a la BD: " + cx.getMensaje());
                return false;
            }

            try (Connection con = cx.getConnection();
                 PreparedStatement ps = con.prepareStatement(sql)) {

                ps.setString(1, mensaje.getNombre());
                ps.setString(2, mensaje.getEmail());
                ps.setString(3, mensaje.getMensaje());

                return ps.executeUpdate() > 0;
            }

        } catch (Exception e) {
            e.printStackTrace();
            return false;

        } finally {
            // Cerramos la conexión de esta instancia
            cx.cerrarConexion();
        }
    }
}
